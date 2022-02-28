# defines the wrapped cauchy distribution with different shape parameter

using Distributions
using StatsFuns
using Random

struct WrappedCauchy{T<:Real} <: ContinuousUnivariateDistribution
    mu::T
    s::T
    c::T
    logS::T
    gamma::T
    function WrappedCauchy{T}(mu::T,s::T) where T<:Real 
        c=sqrt(1+s^2)
        logS=log(s)-log2π
        gamma=log(s+c)
        new{T}(mu,s,c,logS,gamma)
    end
end




Distributions.pdf(d::WrappedCauchy, theta::Real) = 1/2pi * d.s / (d.c - cos(theta-d.mu))
Distributions.logpdf(d::WrappedCauchy, theta::Real) = d.logS-log(d.c - cos(theta-d.mu))
Distributions.rand(rng::AbstractRNG, d::WrappedCauchy) = angle(exp(rand(Cauchy(d.mu,d.gamma))*im))
