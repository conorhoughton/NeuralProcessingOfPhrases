# second toy example

using Turing, Distributions
using Serialization
using Random
using MCMCChains
#Random.seed!(0)

struct WrappedCauchy <: ContinuousUnivariateDistribution
    mu
    gamma
end

Distributions.pdf(d::WrappedCauchy, theta::Real) = 1/2pi * sinh(d.gamma) / (cosh(d.gamma) - cos(theta-d.mu))
Distributions.logpdf(d::WrappedCauchy, theta::Real) = log(sinh(d.gamma)) - log(cosh(d.gamma) - cos(theta-d.mu))-log(2pi)
Distributions.rand(rng::AbstractRNG, d::WrappedCauchy) = angle(exp(rand(Cauchy(d.mu,d.gamma))*im))

mu1=1.0::Float64
mu2=2.0::Float64
thisGamma=0.5::Float64

nS=100

angleData1=rand(WrappedCauchy(mu1,thisGamma),nS)
angleData2=rand(WrappedCauchy(mu2,thisGamma),nS)

angleData=vcat(angleData1,angleData2)

group1=ones(Int64,nS)
group2=2*ones(Int64,nS)

group=vcat(group1,group2)

@model fitWrapped(group,groupN,data) = begin 

    function getAngle(v)
    	atan(v[1],v[2])
    end   

    gamma ~ Exponential(0.5)

    c=Float64[1.0 0.0;0.0 1.0]
    m=zeros(Float64,2)

    mu=[undef,undef]

    for i in 1:groupN
        mu[i]~MvNormal(m,c)
    end
    
#    mu ~ filldist(MvNormal(m,c),groupN)
  
    
    for i in 1:length(data)
        data[i] ~ WrappedCauchy(getAngle(mu[group[i]]),gamma)
    end
    
end

acceptance = 0.99
iterations = 1000



chain = sample(fitWrapped(group,2,angleData), NUTS(acceptance), iterations, progress=false)

#chain = sample(fitWrapped(group,2,angleData) , NUTS(acceptance), MCMCThreads(), iterations, 4)

serialize("multi_example_chains.jls", chain)

