# recover Gauss model
using DrWatson
@quickactivate "StatisticalRethinkingTuring"
using Turing
using StatisticalRethinking
using Distributions


include("custom_gauss_example.jl")

Turing.setprogress!(false)

data=rand(Normal(3,6),1000)


# Define the regression model

@model thisModel(data) = begin
    #priors
    mu ~ Normal(0, 10)
    s ~ Uniform(0, 10)
    #model
    data .~ NewSampler.(mu, s)
end

# Draw the samples

dataModel = thisModel(data)
nchains = 4; sampler = NUTS(0.65); nsamples=2000
chn = sample(dataModel, sampler, nsamples)
