#defines the "spike bundt" distribution

using Distributions
using LinearAlgebra
using Bijectors
using StatsFuns

struct SpikeBundt{T1<:Real,T2<:Real} <: ContinuousMultivariateDistribution
    λ::T1
    τ::T2
end

function Distributions.rand(rng::AbstractRNG, d::SpikeBundt) 
    p=rand(Uniform(0.0,1.0))
    if p<d.λ
        r=rand(Normal(0.0,d.τ))
    else
        r=rand(Uniform(0.0,1.0))
    end
    θ=rand(Uniform(-π,π))
    [r*cos(θ),r*sin(θ)]
end

function Distributions.rand!(rng::AbstractRNG,d::SpikeBundt,x::AbstractArray) 
    p=rand(Uniform(1.0))
    if p<d.λ
        r=rand(Norm(0.0,τ))
    else
        r=rand(Uniform(1.0))
    end
    θ=rand(Uniform(-π,π))
    [r*cos(θ),r*sin(θ)]
end

function Distributions._rand!(rng::AbstractRNG,d::SpikeBundt,x::AbstractArray) 
    p=rand(Uniform(1.0))
    if p<d.λ
        r=rand(Norm(0.0,τ))
    else
        r=rand(Uniform(1.0))
    end
    θ=rand(Uniform(-π,π))
    [r*cos(θ),r*sin(θ)]
end




function insupport(d::SpikeBundt, x::AbstractVector{<:Real})
    return norm(x) < 1
end

function Distributions._logpdf(d::SpikeBundt, x::AbstractVector{<:Real})
    if !insupport(d, x)
        return log(zero(norm(x)))
    end
    return log(pdf(d,x))
end


function Distributions.logpdf(d::SpikeBundt, x::AbstractVector{<:Real})
    if !insupport(d, x)
        return log(zero(norm(x)))
    end
    return log(pdf(d,x))
end

Distributions.length(d::SpikeBundt)=2

function Distributions.pdf(d::SpikeBundt, x::AbstractVector{<:Real})
    r=norm(x)
    val=(d.λ*invsqrt2π / d.τ * exp(-0.5*(r/d.τ)^2)+(1-d.λ))/r
    return r<1 ? val : zero(r)
end

Distributions.sampler(d::SpikeBundt)=d

Bijectors.bijector(d::SpikeBundt) = Identity{1}()

