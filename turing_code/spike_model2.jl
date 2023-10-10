# first go at modelling some data

using Turing
using Serialization
using Random
using MCMCChains
using ArgParse


#Random.seed!(0)

include("general.jl")
include("wrapped_cauchy.jl")
include("slab_spike.jl")

@model function fitWrapped(angles,conditions,participants,electrodes,conditionN,participantN,electrodeN,::Type{T}=Float64) where {T}

    trialN=length(angles)/(conditionN*participantN*electrodeN)

    τ = 1/(2*trialN)

    # σC ~ Exponential()
    # σE ~ Exponential()
    # σP ~ Exponential()

    σ ~ Exponential()
    
    ηCE = Array{T}(undef,(conditionN,electrodeN))

    for c in 1:conditionN
        for e in 1:electrodeN        
            ηCE[c,e] ~ Normal()
        end
    end
      
    x = Array{Vector{T}}(undef,(conditionN,participantN,electrodeN))

    for c in 1:conditionN
        for p in 1:participantN
    	    for e in 1:electrodeN
                λ=logistic(σ*ηCE[c,e])
                x[c,p,e] ~ SlabSpike(λ,τ)
	    end
        end
    end
    

   for i in 1:length(angles)
       
       c=conditions[i]
       p=participants[i]
       e=electrodes[i]
       
       μ=atan(x[c,p,e][1],x[c,p,e][2])
       
       ρ=minimum([1.0,sqrt(x[c,p,e][1]^2 +x[c,p,e][2]^2)])

       γ = -log(ρ)
       
       angles[i] ~ WrappedCauchy(μ,γ)

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
        default = 1000

    end

    return parse_args(s)
end

parsedArgs=parseCommandLine()


runC=38
freqC=parsedArgs["freqC"]

numberP=2
electrodeN=32
conditionN=6

experiment=load(collect(5:4+numberP),freqC)

experiment=experiment[(experiment.freqC.==freqC) .& (experiment.electrode.<=electrodeN),:]


angles=experiment.angle

participants = [x-4 for x in experiment.participant]
conditions   = experiment.conditionC
electrodes   = experiment.electrode

iterations = parsedArgs["iterations"]
acceptance = 0.75

chain = sample(fitWrapped(angles,conditions,participants,electrodes,conditionN,numberP,electrodeN) , NUTS(acceptance) , iterations)

chainName=parsedArgs["name"]

if parsedArgs["runC"]>0
    chainName=chainName*"_r"*string(runC)
end

chainName=chainName*"_f"*string(freqC)*".jls"

serialize(chainName, chain)    