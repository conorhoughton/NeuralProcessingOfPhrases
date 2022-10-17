#defines the "spike bundt" distribution

using Distributions
using LinearAlgebra
using Bijectors
using StatsFuns

struct BetaBundt{T1<:Real,T2<:Real} <: ContinuousMultivariateDistribution
    α::T1
    β::T2
end

function Distributions.rand(rng::AbstractRNG, d::BetaBundt) 
    r=rand(Beta(d.α+1,d.β))
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]
end

function Distributions.rand!(rng::AbstractRNG,d::BetaBundt,x::AbstractArray)
    r=rand(Beta(d.α+1,d.β))
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]
end

function Distributions._rand!(rng::AbstractRNG,d::BetaBundt,x::AbstractArray) 
    r=rand(Beta(d.α+1,d.β))
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]
end

function Distributions.pdf(d::BetaBundt, x::AbstractArray{<:Real})
    ρ=norm(x)
    if ρ<=0 || ρ>=1
        return zero(ρ)
    else
        return Distributions.pdf(Beta(d.α,d.β),ρ)/2π
    end
end

function Distributions.logpdf(d::BetaBundt, x::AbstractArray{<:Real})
    ρ=norm(x)
    if ρ<=0 || ρ>=1
        return log(zero(ρ))
    else
        return Distributions.logpdf(Beta(d.α,d.β),ρ)-log2π
    end
end

function Distributions._logpdf(d::BetaBundt, x::AbstractArray{<:Real})
    ρ=norm(x)
    if ρ<=0 || ρ>=1
        return log(zero(ρ))
    else
        return Distributions._logpdf(Beta(d.α,d.β),ρ)-log2π
    end
end

Distributions.length(d::BetaBundt)=2

Distributions.sampler(d::BetaBundt)=d

Bijectors.bijector(d::BetaBundt) = Identity{1}()



