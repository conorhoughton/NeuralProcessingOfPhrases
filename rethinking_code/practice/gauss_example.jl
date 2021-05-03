# recover Gauss model
using DrWatson
@quickactivate "StatisticalRethinkingTuring"
using Turing
using StatisticalRethinking
using Distributions
Turing.setprogress!(false)

data=rand(Normal(3,3),1000)


# Define the regression model

@model thisModel(data) = begin
    #priors
    mu ~ Normal(0, 10)
    s ~ Uniform(0, 10)
    #model
    data .~ Normal.(mu, s)
end

# Draw the samples

dataModel = thisModel(data)
nchains = 4; sampler = NUTS(0.65); nsamples=2000
chns4 = mapreduce(c -> sample(dataModel, sampler, nsamples), chainscat, 1:nchains)
