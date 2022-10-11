# 1 Running the Sampler

The sampler is invoked through the run_sampler.r script. This takes in the following set of parameters from the command line:

1. **model_file_path** : A string specifiying location of the stan model
2. **iter_n** : Total number of sampler iteratiosn (half go to warmup)
3. **freq_band** : Integer specifying the frequency of interest (phase = 21)
4. **model_id** : String to help identify model fit
5. **n_part** : Number of participants to use in analysis (maximum of 16).

The typical call is:

``` Rscript run_sampler.r "models/model_2t.stan" 2000 21 "m2t" 16 ```

## 1.1 Optimisation
Point estimates of the posterior can be obtained through optmisation. We used this to
give an estimate of the model behaviour for frequencies that were not of interest.

The same procedure applies for optimisation without the choice for participant number:

``` Rscript run_optim.r "models/model_2t.stan" 2000 21 "m2t" ```

# 2 Data efficiency (Figure 8)

The amount of regualrisation necessary depends on the amount of data, we chose to fix
$\nu = 30$ when fitting across different data sizes. This gives the  multivariate t distribution similar behaviour to that of the multivariate normal.

# 3 Plotting scripts

Plotting scripts plots Figures from the paper, saving the output to the correponding folder. These can be run from the command line using the following command:

``` Rscript <plot_script.r> ```

# 4 Acknowledgements
The information provided within the following blog post was adapted and used for the headcap figures.
* https://www.mattcraddock.com/blog/2017/02/25/erp-visualization-creating-topographical-scalp-maps-part-1/

The following threads from the Stan forums were very helpful in highlighting difficulties involved with sampling directional statistics.
* https://discourse.mc-stan.org/t/divergence-treedepth-issues-with-unit-vector/8059/3
* https://discourse.mc-stan.org/t/a-better-unit-vector/26989/17
* https://discourse.mc-stan.org/t/correlated-random-walk-with-measurement-error-trouble-converging/5255/13
