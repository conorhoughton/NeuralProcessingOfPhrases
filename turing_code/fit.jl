# first go at modelling some data

using Turing
using Serialization
using Random
using MCMCChains
using ArgParse


#Random.seed!(0)

include("general.jl")
include("wrapped_cauchy.jl")
include("bundt.jl")

@model function fitWrapped(angles,conditions,participants,electrodes,conditionN,participantN,electrodeN,::Type{T}=Float64) where {T}

 #   itpcC ~ filldist(Beta(0.75,0.75),conditionN

#    itpcC ~    filldist(Normal(),conditionN)
#    itpcE ~    filldist(Normal(),electrodeN) 
#    itpcP ~    filldist(Normal(),participantN) 


    itpcC ~    filldist(Exponential(1.0),conditionN)
    itpcE ~    filldist(Exponential(1.0),electrodeN) 
    itpcP ~    filldist(Exponential(1.0),participantN) 


    bias ~ Exponential(1.0)

    scale ~ Exponential(1.0)


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

      	#r ~ Beta(itpcC[thisCond],1.0)	

#	gamma = -log(logistic(scale*itpcC[thisCond])*logistic(scale*itpcE[thisElec])*logistic(scale*itpcP[thisPart]))-log(logistic(bias))

	gamma = -log(logistic(scale*(itpcC[thisCond]+itpcE[thisElec]+itpcP[thisPart]+bias)))
        
#	gamma = itpcC[thisCond]+itpcE[thisElec]+itpcP[thisPart] + bias

        angles[i] ~ WrappedCauchy(mu,gamma)

    end

end

function parseCommandLine()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--freqC"
        help = "which frequency to run on"
        arg_type = Int
        default = 21
        
        "--runC"
        help = "an optional addition to the output file name"
        arg_type = Int
        default = -1
        
        "--name"
        help = "name root for the output files"
        arg_type = String
        default = "chain"    

        "--iterations"
        help = "number of iterations for the sampler"
        arg_type = Int
        default = 100

    end

    return parse_args(s)
end

parsedArgs=parseCommandLine()


runC=38
freqC=parsedArgs["freqC"]

numberP=2
electrodeN=2
conditionN=6

experiment=load(collect(5:4+numberP),freqC)

experiment=experiment[(experiment.freqC.==freqC) .& (experiment.electrode.<=electrodeN),:]


angles=experiment.angle

participants = [x-4 for x in experiment.participant]
conditions   = experiment.conditionC
electrodes   = experiment.electrode

iterations = parsedArgs["iterations"]
acceptance = 0.75

chain = sample(fitWrapped(angles,conditions,participants,electrodes,conditionN,numberP,electrodeN) , NUTS(acceptance) , MCMCThreads(),iterations,8)

chainName=parsedArgs["name"]

if parsedArgs["runC"]>0
    chainName=chainName*"_r"*string(runC)
end

chainName=chainName*"_f"*string(freqC)*".jls"

serialize(chainName, chain)    
