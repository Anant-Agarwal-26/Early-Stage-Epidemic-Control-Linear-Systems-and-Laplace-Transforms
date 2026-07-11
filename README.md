# Early-Stage-Epidemic-Control-Linear-Systems-and-Laplace-Transforms

## Overview
This project investigates the dynamics of an infectious disease outbreak and the impact of delayed quarantine interventions. 
By restricting the classical SIR epidemiological model to its early-stage linear approximation (where the susceptible population is approximately equal to the total population), the project applies matrix methods and Laplace transforms to mathematically model public health strategies and establish concrete outbreak thresholds. 

## Mathematical Framework
* **Linearized System:** The project models a delayed public health response that removes a constant capacity of Q0 individuals into quarantine starting at day T. This forms a non-homogeneous system of linear Ordinary Differential Equations (ODEs).
* **Stability and R0:** By analyzing the homogeneous system's fundamental matrix and eigenvalues, the model demonstrates that intervention is mathematically necessary if the basic reproduction number (R0) is strictly greater than 1[.
* **Laplace Transforms:** The project applies Laplace transforms to solve the discontinuous forcing function (Heaviside step function) algebraically in the frequency domain, yielding an exact closed-form solution for the infected population over time.
* **Epidemic Collapse Threshold:** An analytical derivation establishes the minimum quarantine capacity required to force the exponential coefficient negative and collapse the epidemic: Q0 > I0 * alpha * e^(alpha * T).

## Real-World Data Integration
The theoretical mathematical model is validated using real-world empirical data:
* **Data Ingestion:** The R script automatically fetches real-world COVID-19 data for Italy (Early 2020) directly from the CSSE global time-series CSV repositories.
* **Parameter Extraction:** Linear regression is applied to the natural log of the active population fraction over the first 20 days to empirically determine the infection growth rate (alpha).
* **Threshold Application:** The analytically derived threshold is calculated using the empirical initial infection (I0) and growth rate (alpha) alongside an approximated 15-day delay (T = 15) representing real-world lockdown timelines. 

## Numerical Simulation
Using the deSolve, tidyr, and ggplot2 packages in R, the project computationally simulates the non-homogeneous system. 
The simulation visualizes three distinct scenarios:
1. **Uncontrolled Growth:** Demonstrates unbound exponential spread, visually overlaid with actual empirical scatter points from the Italy dataset .
2. **Successful Quarantine:** Simulates a scenario where intervention capacity strictly exceeds the mathematical threshold (1.5x threshold), resulting in immediate epidemic collapse .
3. **Weak Quarantine:** Simulates a scenario where capacity falls below the threshold (0.5x threshold), which slows the spread but ultimately fails to invert exponential growth .

## Limitations
A fundamental limitation of this linearized approximation is the assumption that the susceptible population remains roughly equal to the total population. 
Because it ignores the natural saturation effect that occurs in a fully non-linear SIR model as the susceptible pool depletes, the linear system inherently overestimates growth and relies entirely on manual control (Q0) to prevent boundless mathematical expansion.

## Author
* Anant Agarwal - Bachelor of Science in Data Science (BSDS), ISI Bangalore[cite: 2]
