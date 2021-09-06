# first go at modelling some data

using DynamicHMC, Turing
using Serialization
using Random
using MCMCChains

#Random.seed!(0)

include("general.jl")
include("wrapped_cauchy.jl")
include("bundt.jl")


#make a small experiment
participant=5
electrode=5
freqC=45

experiment=load([participant])
experiment=experiment[(experiment.participant.==participant) .& (experiment.electrode.==electrode) .& (experiment.freqC.==freqC),:]


@model function fitWrapped(angles)
    
    gamma ~ Exponential(15.0)
    x ~ Bundt()

    for i in 1:length(angles)
        angles[i]~ WrappedCauchy(atan(x[1],x[2]),gamma)
    end

end

angles=experiment.angle

iterations = 1000
acceptance = 0.95

chain = sample(fitWrapped(angles) , NUTS(acceptance), MCMCThreads(), iterations, 4)

serialize("fit_example_small_chain.jls", chain)    
