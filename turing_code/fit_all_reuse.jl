# first go at modelling some data

using DynamicHMC, Turing
using Serialization
using Random
using MCMCChains
using LinearAlgebra

#Random.seed!(0)

include("general.jl")
include("wrapped_cauchy.jl")
include("bundt.jl")

runC=9

freqC=21

numberP=8

electrodeN=8


experiment=load(collect(5:4+numberP),freqC)
experiment=experiment[(experiment.freqC.==freqC) .& (experiment.electrode.<=electrodeN),:]

@model function fitWrapped(angles,conditions,participants,electrodes,conditionN,participantN,electrodeN,::Type{T}=Float64) where {T}

    itpcC ~    filldist(Normal(),conditionN)
#    itpcC ~    filldist(Exponential(1.0),conditionN)	
#     itpcC ~ filldist(Beta(2.0,2.0),conditionN)

    overall ~ Exponential(1.0)

    bias ~ Normal()

    x = Array{Vector{T}}(undef,(participantN,electrodeN))

    for i in 1:participantN
    	for j in 1:electrodeN
            x[i,j] ~ Bundt()
	end
   end

   r=0.0
   mu=0.0

    for i in 1:length(angles)

        thisCond=conditions[i]
        thisPart=participants[i]
	thisElec=electrodes[i]

        mu=atan(x[thisPart,thisElec][1],x[thisPart,thisElec][2])
	scale=norm(x[thisPart,thisElec])

      	#r ~ Beta(itpcC[thisCond],1.0)	


#	gamma = -log(logistic(scale*itpcC[thisCond]))
#	gamma = overall*scale*logistic(itpcC[thisCond])
#	gamma = overall*scale*itpcC[thisCond]
	gamma = -log(logistic(overall*(scale+bias+itpcC[thisCond])))

        angles[i] ~ WrappedCauchy(mu,gamma)

    end

end

angles=experiment.angle

participants = [x-4 for x in experiment.participant]
conditions   = experiment.conditionC
electrodes   = experiment.electrode


iterations = 100
acceptance = 0.75

ϵ = 0.05
τ = 10

#chain = sample(fitWrapped(angles,conditions,participants,electrodes,6,numberP,electrodeN) , DynamicNUTS() , MCMCThreads(),iterations,4)

#chain = sample(fitWrapped(angles,conditions,participants,electrodes,6,numberP,electrodeN) , HMCDA(500, 0.65, 0.3) , MCMCThreads(),iterations,8)

#chain = sample(fitWrapped(angles,conditions,participants,electrodes,6,numberP,electrodeN) , SGHMC((0.01,0.1)) , MCMCThreads(),iterations,4)

chain = sample(fitWrapped(angles,conditions,participants,electrodes,6,numberP,electrodeN) , NUTS(acceptance) , MCMCThreads(),iterations,8)

serialize("reuse_"*string(runC)*"_p"*string(numberP)*"_f"*string(freqC)*".jls", chain)    
