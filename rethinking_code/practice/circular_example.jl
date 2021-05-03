# recover Gauss model
using DrWatson
@quickactivate "StatisticalRethinkingTuring"
using Turing
using StatisticalRethinking
using Distributions
using Base.Math

Turing.setprogress!(false)

data=rand(Normal(0,1),1000)
data=rem2pi.(data,RoundNearest)



@model thisModel(data) = begin
    #priors
    mu ~ Uniform(-pi, pi)
    s ~ Uniform(0, 10)
    #model
    for i in eachindex(data)
        original ~ Normal(mu,s)
        data[i] = rem2pi(original,RoundNearest)
    end
end

# Draw the samples

dataModel = thisModel(data)
nchains = 4; sampler = NUTS(0.65); nsamples=2000
chns4 = mapreduce(c -> sample(dataModel, sampler, nsamples), chainscat, 1:nchains)
