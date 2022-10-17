#defines the "spike bundt" distribution

using Distributions
using LinearAlgebra
using Bijectors
using StatsFuns

struct ExpBundt{T<:Real} <: ContinuousMultivariateDistribution
    θ::T
end

scale(d::ExpBundt) = d.θ
rate(d::ExpBundt) = inv(d.θ)

function Distributions.rand(rng::AbstractRNG, d::ExpBundt) 
    r=rand(Exponential(d.θ))
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]
end

function Distributions.rand!(rng::AbstractRNG,d::ExpBundt,x::AbstractArray) 
    r=rand(Exponential(d.θ))
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]
end

function Distributions._rand!(rng::AbstractRNG,d::ExpBundt,x::AbstractArray) 
    r=rand(Exponential(d.θ))
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]
end

function Distributions.pdf(d::ExpBundt, x::AbstractVector{<:Real})
    λ = rate(d)
    r = norm(x)
    z = λ^2 / 2π * exp(-λ * r)
    return z
end

function Distributions.logpdf(d::ExpBundt, x::AbstractVector{<:Real})
    λ = rate(d)
    r = norm(x)
    z = -log2π+2log(λ) - λ * r-log(r)
    return z
end


function Distributions._logpdf(d::ExpBundt, x::AbstractVector{<:Real})
    λ = rate(d)
    r = norm(x)
    z = -log2π+2log(λ) - λ * r-log(r)
    return z
end


Distributions.length(d::ExpBundt)=2

Distributions.sampler(d::ExpBundt)=d

Bijectors.bijector(d::ExpBundt) = Identity{1}()



