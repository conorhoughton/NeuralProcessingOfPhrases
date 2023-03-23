# 1 Data

The file ```full_data.csv``` is required by the stan code. It can be generated using the ```make_stan_data.jl``` script in the julia folder.

Once this file has been generated it is necessary to run the ```convert_cn.r``` script. This changes the format of the complex number representation in the original file to one that works with R's ```as.complex``` function. This can take a little while to run but is only necessary to perform once, and saves time over changing this representation within each script.

Analysis scripts for the statistical learning data (Pinto et al. 2022), are included, but the data is not open source. The corresponding stan model for this data is: ```models/model_2t_sl.stan```. The frequentist/ITPC analysis and plotting is contained in **sl_data/ITPC**, and plotting for the Bayesian results is in **sl_data/Bayes**.

# 2 Directory Layout

The scripts expect the following directory layout:

* **data/..** : All data files should be placed here.
* **fitted_models/..** : This is where fitted models are saved.
* **fitted_models/optim/..** : This is where optimisation fits are saved.
* **models/..** : The location of the .stan model files.
* **plots/..** : Plots and plotting scripts.

# 3 Sampling

The sampler is invoked through the run_sampler.r script. This takes in the following set of parameters from the command line:

1. **model_file_path** : A string specifiying location of the stan model.
2. **iter_n** : Total number of sampler iteratiosn (half go to warmup).
3. **freq_band** : Integer specifying the frequency of interest (phase = 21).
4. **model_id** : String to help identify model fit.
5. **n_part** : Number of participants to use in analysis (maximum of 16).

The typical call is:

``` Rscript run_sampler.r "models/model_2t.stan" 2000 21 "m2t" 16 ```

## 3.1 Optimisation
Point estimates of the posterior can be obtained through optmisation. We used this to
give an estimate of the model behaviour for frequencies that were not of interest.

The same procedure applies for optimisation without the choice for participant number or the unique string:

``` Rscript run_optim.r "models/model_2t.stan" 0 21 ```

For point estimates the iteration argument is passed as zero.

# 4 Plotting scripts

Plotting scripts plots Figures from the paper, saving the output to the correponding folder. These can be run from the command line using the following command:

``` Rscript <plot_script.r> ```

# 5 Simulation

Simulation experiments and SBC can be found in the **simulation/..** directory.

# 6 Acknowledgements
The information provided within the following blog post was adapted and used for the headcap figures:
* https://www.mattcraddock.com/blog/2017/02/25/erp-visualization-creating-topographical-scalp-maps-part-1/

The following threads from the Stan forums were very helpful in highlighting difficulties involved with sampling directional statistics:
* https://discourse.mc-stan.org/t/divergence-treedepth-issues-with-unit-vector/8059
* https://discourse.mc-stan.org/t/a-better-unit-vector/26989/
