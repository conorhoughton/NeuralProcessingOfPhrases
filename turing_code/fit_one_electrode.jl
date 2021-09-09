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

electrode=rand(1:36)
freqC=21

experiment=load(collect(5:20))
experiment=experiment[(experiment.electrode.==electrode) .& (experiment.freqC.==freqC),:]

gammaWidth=15.0

@model function fitWrapped(angles,conditions,participants,conditionN,participantN,::Type{T}=Float64) where {T}

    gammaC ~ filldist(Exponential(gammaWidth),conditionN)

    gammaCP = Array{T}(undef,(conditionN,participantN))

    for i in 1:conditionN
        for j in 1:participantN
            gammaCP[i,j] ~ Exponential(gammaC[i])
        end
    end

    x = Vector{Vector{T}}(undef,participantN)
    
    for i in 1:participantN
        x[i] ~ Bundt()
    end

    for i in 1:length(angles)
        thisCond=conditions[i]
        thisPart=participants[i]
        mu=atan(x[thisPart][1],x[thisPart][2])
        angles[i] ~ WrappedCauchy(mu,gammaCP[thisCond,thisPart])
    end

end

angles=experiment.angle

participants = [x-4 for x in experiment.participant]
conditions   = experiment.conditionC


iterations = 1000
acceptance = 0.99

chain = sample(fitWrapped(angles,conditions,participants,6,16) , NUTS(acceptance), MCMCThreads(),iterations,4)

serialize("fit_one_electrode_chain_"*string(electrode)*".jls", chain)    
