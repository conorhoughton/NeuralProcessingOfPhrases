#defines the "bundt" distribution

using Distributions
using LinearAlgebra
using Bijectors

struct Bundt <: ContinuousMultivariateDistribution
end

Distributions.length(d::Bundt)=2
Distributions.pdf(d::Bundt, x::AbstractVector{<:Real}) = 1/4pi * norm(x)*exp(-norm(x))
Distributions.logpdf(d::Bundt, x::AbstractVector{<:Real}) = log(norm(x)) - norm(x)-log(4pi)
Distributions._logpdf(d::Bundt,x::AbstractVector{<:Real}) = log(norm(x)) - norm(x)-log(4pi)
function Distributions.rand(rng::AbstractRNG, d::Bundt) 
    r=rand(Gamma())
    theta=rand(Uniform(-pi,pi))
    [r*cos(theta),r*sin(theta)]
end

function Distributions.rand!(rng::AbstractRNG,d::Bundt,x::AbstractArray{T}) where T<:Real 
    r=rand(Gamma())
    theta=rand(Uniform(-pi,pi))
    x=[r*cos(theta),r*sin(theta)]
end

function Distributions._rand!(rng::AbstractRNG,d::Bundt,x::AbstractArray{T}) where T<:Real 
    r=rand(Gamma())
    theta=rand(Uniform(-pi,pi))
    x=[r*cos(theta),r*sin(theta)]
end

Distributions.sampler(d::Bundt)=d

#Bijectors.bijector(::Bundt) = PDBijector()

Bijectors.bijector(d::Bundt) = Identity{1}()
