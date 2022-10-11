# Running the Sampler

The sampler is invoked through the run_sampler.r script. This takes in a set of parameters to
define the data to run on, any any sampling parameters:

model_file_path: A string specifiying location of the stan model
iter_n: Total number of sampler iteratiosn (half go to warmup)
freq_band: Specify what freqeuncy to fit for (21  = phase)
model_id: String to help identify model fit
n_part : number of participants to use in analysis. (max is 16.)

The typical call is:

Rscript run_sampler.r "models/model_2t.stan" 2000 21 "m2t" 16

Then explain for optimisation.

# Optimisation
Point estimates of the posterior can be obtained through optmisation. We used this to
give a rough estimate of the model Behvaiour for frequencies that were not of interest.
We required a quick check against the sample results and this was an efficient way to do it. This is becuase
the sampler is quite expensive to run across all 58 frequecies.

# Data efficiency (Figure 8)

The amount of regualrisation necessary depends on the amount of data, we chose to fix
nu at 30 when testing different participant sizes to help keep the sampler well behaved at lower data sizes.
This brings the multivariate t distribution much closer to a multivariate normal.

# Plotting scripts

Plotting scripts are self contained scripts whos title identifies them with the corresponding
figure in the manuscript.

# Acknowledgements
For the EEG headcaps the information provided within the following blog post was helpful.
https://www.mattcraddock.com/blog/2017/02/25/erp-visualization-creating-topographical-scalp-maps-part-1/

The following information from the Stan forums was also of use when considering model construction.
https://discourse.mc-stan.org/t/divergence-treedepth-issues-with-unit-vector/8059/3
https://discourse.mc-stan.org/t/a-better-unit-vector/26989/17
https://discourse.mc-stan.org/t/correlated-random-walk-with-measurement-error-trouble-converging/5255/13
