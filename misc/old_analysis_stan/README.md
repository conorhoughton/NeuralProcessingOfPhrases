Models are run through the bash script.

./run_model.sh FILE ITER FREQ ID

FILE : Stan model file location (String).
ITER : How many iteration to run MCMC, if optimisation how many samples from the approximate posterior.
FREQ : What frequency to run for.
ID   : String to ID the model fit when saved, can be whatever.

./run_model.sh "models/model_1_opt.stan" 1000 21 "model_1_opt"

Switching between MCMC and optimisation is done by commenting out either marked block in sample_model.r. The option will be added to
the bash script when approximate algorithm/parameters are better decided.

Models for optimisation may need to be written differently than those for HMC, stan models ending with "opt" are for use
with optimisation.