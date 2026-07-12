library(deSolve)
library(ggplot2)
library(tidyr)
library(gridExtra)

# 1. Define the Non-Homogeneous Linear System
linear_quarantine <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    # Heaviside step function: Quarantine capacity Q0 activates at day T
    current_Q <- ifelse(time >= delay_T, Q0, 0)
    # Linear ODEs from the analytical derivation
    dI <- alpha * I - current_Q
    dQ <- current_Q - delta * Q
    # Prevent populations from mathematically dropping below zero
    dI <- ifelse(I <= 0 & dI < 0, 0, dI)
    dQ <- ifelse(Q <= 0 & dQ < 0, 0, dQ)
    return(list(c(dI, dQ)))
  })
}

# 2. Initial conditions and restricted time grid
init_state <- c(I = 0.01, Q = 0.0)
times <- seq(0, 40, by = 0.1)

# 3. Parameters
params_no_control <- c(alpha = 0.15, delta = 0.1, Q0 = 0.0, delay_T = 0)
params_control <- c(alpha = 0.15, delta = 0.1, Q0 = 0.03, delay_T = 15)
params_weak <- c(alpha = 0.15, delta = 0.1, Q0 = 0.012, delay_T = 15) # Below threshold

# 4. Solve the ODEs
out_no <- as.data.frame(ode(y = init_state, times = times, func = linear_quarantine, parms = params_no_control))
out_yes <- as.data.frame(ode(y = init_state, times = times, func = linear_quarantine, parms = params_control))
out_weak <- as.data.frame(ode(y = init_state, times = times, func = linear_quarantine, parms = params_weak))

out_no_long <- pivot_longer(out_no, cols = c("I", "Q"), names_to = "Compartment", values_to = "Fraction")
out_yes_long <- pivot_longer(out_yes, cols = c("I", "Q"), names_to = "Compartment", values_to = "Fraction")
out_weak_long <- pivot_longer(out_weak, cols = c("I", "Q"), names_to = "Compartment", values_to = "Fraction")

# 5. Plotting
line_colors <- c("I" = "red", "Q" = "purple")
shared_theme <- theme_bw() + theme(legend.position = "bottom", plot.title = element_text(hjust = 0.5, size = 10))

plot1 <- ggplot(out_no_long, aes(x = time, y = Fraction, color = Compartment)) +
  geom_line(linewidth = 1) +
  scale_color_manual(values = line_colors, labels = c("I" = "Active Infected", "Q" = "Quarantined")) +
  labs(title = "Uncontrolled Growth", x = "Time (Days)", y = "Population Fraction") +
  coord_cartesian(ylim = c(0, 0.12)) + shared_theme

plot2 <- ggplot(out_yes_long, aes(x = time, y = Fraction, color = Compartment)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = 15, linetype = "dashed", color = "black") +
  scale_color_manual(values = line_colors, labels = c("I" = "Active Infected", "Q" = "Quarantined")) +
  labs(title = "Successful Quarantine (Q0 = 0.03)", x = "Time (Days)", y = "") +
  coord_cartesian(ylim = c(0, 0.12)) + shared_theme

plot3 <- ggplot(out_weak_long, aes(x = time, y = Fraction, color = Compartment)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = 15, linetype = "dashed", color = "black") +
  scale_color_manual(values = line_colors, labels = c("I" = "Active Infected", "Q" = "Quarantined")) +
  labs(title = "Weak Quarantine (Q0 = 0.012)", x = "Time (Days)", y = "") +
  coord_cartesian(ylim = c(0, 0.12)) + shared_theme

combined_plot <- grid.arrange(plot1, plot2, plot3, ncol = 3)
