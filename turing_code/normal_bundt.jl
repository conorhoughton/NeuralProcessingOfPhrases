#defines the "spike bundt" distribution

using Distributions
using LinearAlgebra
using Bijectors
using StatsFuns

struct NormalBundt{T<:Real} <: ContinuousMultivariateDistribution
    σ::T
end

function Distributions.rand(rng::AbstractRNG, d::NormalBundt) 
    r=rand(Normal(0.0,d.σ))
    θ=rand(Uniform(-π,π))
    [r*cos(θ),r*sin(θ)]
end

function Distributions.rand!(rng::AbstractRNG,d::NormalBundt,x::AbstractArray) 
    r=rand(Normal(0.0,d.σ))
    θ=rand(Uniform(-π,π))
    [r*cos(θ),r*sin(θ)]
end

function Distributions._rand!(rng::AbstractRNG,d::NormalBundt,x::AbstractArray) 
    r=rand(Normal(0.0,d.σ))
    θ=rand(Uniform(-π,π))
    [r*cos(θ),r*sin(θ)]
end


function Distributions._logpdf(d::NormalBundt, x::AbstractVector{<:Real})
    r=norm(x)
    return -0.5*log2π - log(d.σ) - 0.5*(r/d.σ)^2 - log(r)
end


function Distributions.logpdf(d::NormalBundt, x::AbstractVector{<:Real})
    r=norm(x)
    return -0.5*log2π - log(d.σ) - 0.5*(r/d.σ)^2 - log(r)
end

Distributions.length(d::NormalBundt)=2

function Distributions.pdf(d::NormalBundt, x::AbstractVector{<:Real})
    r=norm(x)
    val=invsqrt2π / d.τ * exp(-0.5*(r/d.τ)^2)/r
end

Distributions.sampler(d::NormalBundt)=d

Bijectors.bijector(d::NormalBundt) = Identity{1}()

