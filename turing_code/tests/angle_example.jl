# first toy example

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

mu=1.0::Float64
gamma=0.5::Float64

nS=100
angleData=rand(WrappedCauchy(mu,gamma),nS)

@model fitWrapped(data) = begin

    gamma ~ Exponential(0.5)
    mu ~ Uniform(-pi,pi)

    for i in 1:length(data)
        data[i] ~ WrappedCauchy(mu,gamma)
    end
    
end

epsilon = 0.01
tau = 10
iterations = 1000

chain = sample(fitWrapped(angleData), NUTS(0.85), iterations, progress=true)

    
