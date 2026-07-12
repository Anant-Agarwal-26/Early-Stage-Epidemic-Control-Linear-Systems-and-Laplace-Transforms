library(deSolve)
library(ggplot2)
library(tidyr)
library(gridExtra)
library(dplyr)

# ---------------------------------------------------------
# 1. FETCH AND CLEAN REAL-WORLD DATA
# ---------------------------------------------------------
url_confirmed <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
url_deaths <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
url_recovered <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"

raw_confirmed <- read.csv(url_confirmed)
raw_deaths <- read.csv(url_deaths)
raw_recovered <- read.csv(url_recovered)

# Isolate Italy's raw numbers
italy_confirmed <- as.numeric(raw_confirmed[raw_confirmed$Country.Region == "Italy", 5:ncol(raw_confirmed)])
italy_deaths <- as.numeric(raw_deaths[raw_deaths$Country.Region == "Italy", 5:ncol(raw_deaths)])
italy_recovered <- as.numeric(raw_recovered[raw_recovered$Country.Region == "Italy", 5:ncol(raw_recovered)])

# Convert to Active Population Fraction
N <- 60000000 
italy_active_fraction <- (italy_confirmed - italy_deaths - italy_recovered) / N

start_day <- min(which(italy_confirmed > 100))
empirical_time <- 0:40
empirical_active <- italy_active_fraction[start_day:(start_day + 40)]
real_world_data <- data.frame(time = empirical_time, Fraction = empirical_active)

# ---------------------------------------------------------
# 2. EXTRACT EMPIRICAL PARAMETERS
# ---------------------------------------------------------
model <- lm(log(Fraction) ~ time, data = real_world_data[1:20, ])
empirical_alpha <- as.numeric(coef(model)["time"])
empirical_I0 <- as.numeric(real_world_data$Fraction[1])
empirical_T <- 15

# Calculate the EXACT threshold
empirical_threshold <- empirical_I0 * empirical_alpha * exp(empirical_alpha * empirical_T)
Q_success <- empirical_threshold * 1.5 

# ---------------------------------------------------------
# 3. DEFINE AND SOLVE THE ODE
# ---------------------------------------------------------
linear_quarantine <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    current_Q <- ifelse(time > delay_T, Q0, 0)
    
    dI <- alpha * I - current_Q
    dQ <- current_Q - delta * Q
    
    dI <- ifelse(I <= 0 & dI < 0, 0, dI)
    dQ <- ifelse(Q <= 0 & dQ < 0, 0, dQ)
    
    return(list(c(dI, dQ)))
  })
}

init_state <- c(I = 0.01, Q = 0.0)
times <- seq(0, 40, by = 0.1)

params_yes <- c(alpha = 0.15, delta = 0.1, Q0 = 0.03, delay_T = 15)

out_yes <- as.data.frame(ode(y = init_state, times = times, func = linear_quarantine, parms = params_yes))
out_yes_long <- pivot_longer(out_yes, cols = c("I", "Q"), names_to = "Compartment", values_to = "Fraction")

# ---------------------------------------------------------
# 4. PLOTTING
# ---------------------------------------------------------
# GRAPH 1: THE REAL-WORLD EMPIRICAL DATA (ITALY)
plot_real_data <- ggplot(data = real_world_data, aes(x = time, y = Fraction)) +
  geom_line(color = "black", linewidth = 1) +
  geom_point(color = "black", size = 1.5, alpha = 0.7) +
  labs(
    title = "Real-World Epidemic Trajectory (Italy)",
    subtitle = "Observed active infection fraction (First 40 days)",
    x = "Time (Days)",
    y = "Population Fraction"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 10)
  )

# GRAPH 2: THE THEORETICAL SUCCESSFUL QUARANTINE STRATEGY
plot_theoretical_success <- ggplot(out_yes_long, aes(x = time, y = Fraction, color = Compartment)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = empirical_T, linetype = "dashed", color = "darkgray") +
  scale_color_manual(values = c("I" = "red", "Q" = "purple"), 
                     labels = c("I" = "Active Infected (I)", "Q" = "Quarantined (Q)")) +
  labs(
    title = sprintf("Theoretical Strategy: Successful Quarantine (Q0 = %.5f)", Q_success),
    subtitle = "Mathematical projection if quarantine capacity exceeds threshold",
    x = "Time (Days)",
    y = "Population Fraction",
    color = "Compartment"
  ) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 10)
  )

# Combine both graphs side-by-side
combined_plot <- grid.arrange(plot_real_data, plot_theoretical_success, ncol = 2)

# Print the final combined plot to the viewer
print(combined_plot)