#defines the "bundt" distribution

using Distributions
using LinearAlgebra
using Bijectors
using StatsFuns

struct Bundt <: ContinuousMultivariateDistribution
end

Distributions.length(d::Bundt)=2
Distributions.pdf(d::Bundt, x::AbstractVector{<:Real}) = 1/2π * norm(x)*exp(-norm(x))
Distributions.logpdf(d::Bundt, x::AbstractVector{<:Real}) = log(norm(x)) - norm(x)-log2π
Distributions._logpdf(d::Bundt,x::AbstractVector{<:Real}) = log(norm(x)) - norm(x)-log2π

function Distributions.rand(rng::AbstractRNG, d::Bundt) 
    r=rand(Gamma(2.0))
    θ=rand(Uniform(-π,π))
    [r*cos(θ),r*sin(θ)]
end

function Distributions.rand!(rng::AbstractRNG,d::Bundt,x::AbstractArray) 
    r=rand(Gamma(2.0))
    θ=rand(Uniform(-π,π))
    x=[r*cos(θ),r*sin(θ)]
end

function Distributions._rand!(rng::AbstractRNG,d::Bundt,x::AbstractArray) 
    r=rand(Gamma(2.0))
    θ=rand(Uniform(-π,π))
    x=[r*cos(θ),r*sin(θ)]
end

Distributions.sampler(d::Bundt)=d

#Bijectors.bijector(::Bundt) = PDBijector()

Bijectors.bijector(d::Bundt) = Identity{1}()
