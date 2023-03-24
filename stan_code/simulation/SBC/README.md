Simulation based calibration for the Bayesian model.

```run_sbc.r``` calculates rank statitics for a variety of parameters, or transformed parameters of the Bayesian model.

```plot_sbc.r``` plots the histogram of ranks statistics and ECDF for a chosen parameter.


If running parameters are changed in ```run_sbc.r```, be sure to reflect them in ```plot_sbc.r``` otherwise the resulting plots will be incorrect. This corresponds to:
* the total number of iterations
* the number of samples per iteration
