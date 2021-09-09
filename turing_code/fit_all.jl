# first go at modelling some data

using DynamicHMC, Turing
using Serialization
using Random
using MCMCChains

#Random.seed!(0)

include("general.jl")
include("wrapped_cauchy.jl")
include("bundt.jl")

freqC=21

experiment=load(collect(5:20))
experiment=experiment[(experiment.freqC.==freqC),:]

@model function fitWrapped(angles,conditions,participants,electrodes,conditionN,participantN,electrodeN,::Type{T}=Float64) where {T}

    itpcC ~ filldist(Beta(0.5,2),conditionN)

    probP ~ filldist(Beta(0.5,0.5),participantN)
    probE ~ filldist(Beta(0.5,0.5),electrodeN)

    x = Vector{Vector{T}}(undef,participantN)
    
    for i in 1:participantN
        x[i] ~ Bundt()
    end

    for i in 1:length(angles)
        thisCond=conditions[i]
        thisPart=participants[i]
	thisElec=electrodes[i]
        mu=atan(x[thisPart][1],x[thisPart][2])
      	gamma=-log(probP[thisPart]*probE[thisElec]*itpcC[thisCond])
        angles[i] ~ WrappedCauchy(mu,gamma)
    end

end

angles=experiment.angle

participants = [x-4 for x in experiment.participant]
conditions   = experiment.conditionC
electrodes   = experiment.electrode


iterations = 1000
acceptance = 0.99

chain = sample(fitWrapped(angles,conditions,participants,electrodes,6,16,32) , NUTS(acceptance), MCMCThreads(),iterations,4)

serialize("fit_all_chain_long.jls", chain)    
