# Early-Stage-Epidemic-Control-Linear-Systems-and-Laplace-Transforms

## Overview
This project investigates the dynamics of an infectious disease outbreak and the impact of delayed quarantine interventions. 
By restricting the classical SIR epidemiological model to its early-stage linear approximation (where the susceptible population is approximately equal to the total population), the project applies matrix methods and Laplace transforms to mathematically model public health strategies and establish concrete outbreak thresholds. 

## Mathematical Framework
* **Linearized System:** The project models a delayed public health response that removes a constant capacity of Q0 individuals into quarantine starting at day T. This forms a non-homogeneous system of linear Ordinary Differential Equations (ODEs) verified by Picard's Existence and Uniqueness Theorem:
  `I'(t) = α * I(t) - Q0 * H(t - T)`
  `Q'(t) = Q0 * H(t - T) - δ * Q(t)`
* **Stability and R0:** By analyzing the homogeneous system's diagonal matrix A, its eigenvalues are explicitly found to be λ1 = α and λ2 = -δ. The resulting fundamental matrix Φ(t) = diag(e^(αt), e^(-δt)) demonstrates that if α > 0, the infection exhibits unbounded exponential growth, making intervention mathematically necessary if the basic reproduction number (R0 = (β * N) / γ) is strictly greater than 1.
* **Laplace Transforms:** The project applies Laplace transforms (L) and the Second Shifting Theorem to solve the discontinuous Heaviside step function H(t-T) algebraically in the frequency domain, yielding an exact closed-form solution for the active infected population over time:
  `I(t) = I0 * e^(αt) - (Q0 / α) * [e^(α(t-T)) - 1] * H(t-T)`
* **Epidemic Collapse Threshold:** An analytical derivation isolates the exponential coefficient for t >= T, establishing the minimum quarantine capacity required to force it negative and collapse the epidemic: 
  `Q0 > I0 * α * e^(αT)`

## Real-World Data Integration
The theoretical mathematical model evaluates real-world empirical data trends alongside the ideal scenarios:
* **Data Ingestion:** The R script automatically fetches real-world COVID-19 data for Italy (Early 2020) directly from the CSSE global time-series CSV repositories.
* **Parameter Extraction:** Linear regression is applied to the natural log of the active population fraction over the first 20 days to empirically determine the infection growth rate (α).
* **Threshold Application:** The analytically derived threshold is calculated using the empirical initial infection (I0) and growth rate (α) alongside an approximated 15-day delay (T = 15) representing real-world lockdown timelines. For this specific Italy dataset, the script yields an exact minimum Q_success capacity threshold of approximately 3.021641e-05 (isolating ~1,813 individuals per day across a population of 60 million).

## Numerical Simulation & Visualization
Using the `deSolve`, `tidyr`, and `ggplot2` packages in R, the project computationally simulates the non-homogeneous system. The visualization framework features two decoupled graphical perspectives to isolate reality from simulation:
1. **Real-World Empirical Trajectory:** A standalone graph mapping Italy's actual active infection fraction over the first 40 days, displaying a strictly increasing exponential path that lacks an immediate quarantine downturn due to logistical boundaries.
2. **Theoretical Control Strategies:** Projections simulating the exact predictive behavior of the derived equations under varying containment parameters:
   * *Uncontrolled Growth:* Demonstrates unbound exponential spread when Q0 = 0.
   * *Successful Quarantine:* Simulates an ideal containment scenario where capacity strictly exceeds the mathematical threshold (Q0 = 0.03), causing the curve to peak precisely at t = T and immediately collapse.
   * *Weak Quarantine:* Simulates a scenario where capacity falls below the threshold (Q0 = 0.012), slowing the transmission rate but failing to invert the long-term exponential growth.

## Limitations
A fundamental limitation of this linearized approximation is the assumption that the susceptible population remains roughly constant (S ≈ N). Because it ignores the natural saturation effect that occurs in a fully non-linear SIR model as the susceptible pool depletes (S(t) * I(t)), the linear system inherently overestimates growth and relies entirely on manual control (Q0) to prevent boundless mathematical expansion towards infinity.

## Author
* **Anant Agarwal** (BSD-BG-2402) - Bachelor of Science in Data Science (BSDS), Indian Statistical Institute (ISI) Bangalore
* **Contact:** bsdbg2402@isibang.ac.in
