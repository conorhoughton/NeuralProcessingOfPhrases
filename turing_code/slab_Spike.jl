#defines the "spike bundt" distribution

using Distributions
using LinearAlgebra
using Bijectors
using StatsFuns

struct SlabSpike{T1<:Real,T2<:Real} <: ContinuousMultivariateDistribution
    λ::T1
    τ::T2
end

function Distributions.rand(rng::AbstractRNG, d::SlabSpike) 

    p = rand(Uniform(0.0,1.0))

    if p<d.λ
        r=maximum([0.0,rand(Exponential(d.τ))])
    else
        r=rand(Beta(2.0,1.0))
    end
    
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]

end

function Distributions.rand!(rng::AbstractRNG,d::SlabSpike,x::AbstractArray)
    p = rand(Uniform(0.0,1.0))

    if p<d.λ
        r=minimum([1.0,Gamma(2,d.τ)])
    else
        r=rand(Beta(2.0,1.0))
    end
    
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]

end

function Distributions._rand!(rng::AbstractRNG,d::SlabSpike,x::AbstractArray) 

    p = rand(Uniform(0.0,1.0))

    if p<d.λ
        r=maximum([0.0,rand(Exponential(d.τ))])
    else
        r=rand(Beta(2.0,1.0))
    end
    
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]

end

function Distributions.pdf(d::SlabSpike, x::AbstractArray{<:Real})
    ρ=norm(x)
    if ρ<=0 || ρ>=1
        return zero(ρ)
    else
        return (d.λ*Distributions.pdf(Exponential(1.0),ρ/d.τ)+(1-d.λ))*inv2π
    end
end

function Distributions.logpdf(d::SlabSpike, x::AbstractArray{<:Real})
    ρ=norm(x)
    if ρ<=0 || ρ>=1
        return log(zero(ρ))
    else
        return log(pdf(d,x))
    end
end

function Distributions._logpdf(d::SlabSpike, x::AbstractArray{<:Real})
    ρ=norm(x)
    if ρ<=0 || ρ>=1
        return log(zero(ρ))
    else
        return log(pdf(d,x))
    end
end

Distributions.length(d::SlabSpike)=2

Distributions.sampler(d::SlabSpike)=d

Bijectors.bijector(d::SlabSpike) = Identity{1}()



