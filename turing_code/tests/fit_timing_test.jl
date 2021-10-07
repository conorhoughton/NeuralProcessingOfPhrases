# first go at modelling some data

using DynamicHMC, Turing
using Serialization
using Random
using MCMCChains

#Random.seed!(0)

include("general.jl")
include("wrapped_cauchy.jl")

freqC=21

numberP=16

experiment=load(collect(5:4+numberP))
experiment=experiment[(experiment.freqC.==freqC),:]

@model function fitWrapped(angles,conditions,participants,electrodes,conditionN,participantN,electrodeN,::Type{T}=Float64) where {T}

#    itpcC ~ filldist(Beta(2.0,2.0),conditionN)

    itpcC ~ filldist(Uniform(0.0,1.0),conditionN)
   
    x = Array{T}(undef,(participantN,electrodeN))
    
    for i in 1:participantN
    	for j in 1:electrodeN
            x[i,j] ~ Uniform(-pi,pi)
	end
    end
    
    r ~ filldist(Exponential(10.0),length(angles))

    for i in 1:length(angles)

        thisCond=conditions[i]
        thisPart=participants[i]
	thisElec=electrodes[i]

        mu=x[thisPart,thisElec]
	gamma = r[i]*itpcC[thisCond]

        angles[i] ~ WrappedCauchy(mu,gamma)
    end

end

angles=experiment.angle

participants = [x-4 for x in experiment.participant]
conditions   = experiment.conditionC
electrodes   = experiment.electrode


iterations = 1000
acceptance = 0.99

chain = sample(fitWrapped(angles,conditions,participants,electrodes,6,numberP,32) , NUTS(acceptance), MCMCThreads(),iterations,4)

serialize("fit_timing_test_p"*string(numberP)*".jls", chain)    