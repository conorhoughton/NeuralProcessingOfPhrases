using Distributions
import Distributions: @check_args
using Base.Math


struct WrappedCauchy{T<:Real} <: ContinuousUnivariateDistribution
    mu::T
    gamma::T
end

function WrappedCauchy(mu::T, gamma::T; check_args=true) where {T<:Real}
    check_args && @check_args(WrappedCauchy, gamma > zero(gamma))
    return WrappedCauchy{T}(mu, gamma)
end

WrappedCauchy(mu::Real, gamma::Real) = WrappedCauchy(promote(mu, gamma)...)
WrappedCauchy(mu::Integer, gamma::Integer) = WrappedCauchy(float(mu), float(gamma))
WrappedCauchy(mu::T) where {T<:Real} = WrappedCauchy(mu, one(T))
WrappedCauchy() = WrappedCauchy(0.0, 1.0, check_args=false)

function convert(::Type{WrappedCauchy{T}}, mu::Real, gamma::Real) where T<:Real
    WrappedCauchy(T(mu), T(gamma))
end

function convert(::Type{WrappedCauchy{T}}, d::WrappedCauchy{S}) where {T <: Real, S <: Real}
    WrappedCauchy(T(d.mu), T(d.gamma), check_args=false)
end



function Distributions.rand(d::WrappedCauchy)
    r=rand(Cauchy(d.mu,d.gamma))
    rem2pi(r,RoundNearest)
end

#Distributions.rand(d::WrappedCauchy) = rand(d) 
Distributions.logpdf(d::WrappedCauchy, x::Real) = log(sinh(d.gamma)/(cosh(d.gamma)-cos(x-d.mu)))-log(2*pi)

Distributions.maximum(d::WrappedCauchy) = pi
Distributions.minimum(d::WrappedCauchy) = pi
