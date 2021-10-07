# using a two-d distribution to sample the angle

using Turing, Distributions
using Serialization
using Random
using MCMCChains
include("wrapped_cauchy.jl")
include("bundt.jl")

mu1=-1.0
mu2= 1.0
thisGamma=0.5

nS=100

angleData1=rand(WrappedCauchy(mu1,thisGamma),nS)
angleData2=rand(WrappedCauchy(mu2,thisGamma),nS)

angleData=vcat(angleData1,angleData2)

group1=ones(Int64,nS)
group2=2*ones(Int64,nS)

group=vcat(group1,group2)

@model fitWrapped(group,groupN,data) = begin 

    gamma ~ Exponential(0.5)

    
    x=Vector{Vector{Real}}(undef, 2)

    for i in 1:groupN
        x[i]~Bundt()
    end

            
    #    a ~ filldist(Normal(),groupN)
    #    b ~ filldist(Normal(),groupN)
    
    #    mu ~ filldist(MvNormal(m,c),groupN)
  
    
    for i in 1:length(data)
        data[i] ~ WrappedCauchy(atan(x[group[i]][1],x[group[i]][2]),gamma)
     end
    
end

acceptance = 0.99
iterations = 1000



chain = sample(fitWrapped(group,2,angleData), NUTS(acceptance), iterations, progress=false)

#chain = sample(fitWrapped(group,2,angleData) , NUTS(acceptance), MCMCThreads(), iterations, 4)

serialize("multi_example_chains.jls", chain)

