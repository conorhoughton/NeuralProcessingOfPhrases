# defines the wrapped cauchy distribution

using Distributions

struct WrappedCauchy{T<:Real} <: ContinuousUnivariateDistribution
    mu::T
    gamma::T
end

Distributions.pdf(d::WrappedCauchy, theta<:Real) = 1/2pi * sinh(d.gamma) / (cosh(d.gamma) - cos(theta-d.mu))
Distributions.logpdf(d::WrappedCauchy, theta<:Real) = log(sinh(d.gamma)) - log(cosh(d.gamma) - cos(theta-d.mu))-log(2pi)
Distributions.rand(rng::AbstractRNG, d::WrappedCauchy) = angle(exp(rand(Cauchy(d.mu,d.gamma))*im))
