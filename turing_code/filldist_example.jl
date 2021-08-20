# second toy example - now using filldist

using Turing, Distributions
using Random
Random.seed!(0)

struct WrappedCauchy <: ContinuousUnivariateDistribution
    mu
    gamma
end

Distributions.pdf(d::WrappedCauchy, theta::Real) = 1/2pi * sinh(d.gamma) / (cosh(d.gamma) - cos(theta-d.mu))
Distributions.logpdf(d::WrappedCauchy, theta::Real) = log(sinh(d.gamma)) - log(cosh(d.gamma) - cos(theta-d.mu))-log(2pi)
Distributions.rand(rng::AbstractRNG, d::WrappedCauchy) = angle(exp(rand(Cauchy(d.mu,d.gamma))*im))

mu1=1.0::Float64
mu2=2.0::Float64
gamma=0.5::Float64

nS=25

angleData1=rand(WrappedCauchy(mu1,gamma),nS)
angleData2=rand(WrappedCauchy(mu2,gamma),nS)

angleData=vcat(angleData1,angleData2)

group1=ones(Int64,nS)
group2=2*ones(Int64,nS)

group=vcat(group1,group2)

@model function fitWrapped(group,groupN,data) 

    gamma ~ Exponential(0.5)
    mu ~ filldist(Uniform(-pi,pi),groupN)

    for i in 1:length(data)
        data[i] ~ WrappedCauchy(mu[group[i]],gamma)
    end
    
end

epsilon = 0.01
tau = 10
iterations = 1000

chain = sample(fitWrapped(group,2,angleData), NUTS(0.85), iterations, progress=true)

    
