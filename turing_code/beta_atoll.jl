#defines the "spike bundt" distribution

using Distributions
using LinearAlgebra
using Bijectors
using StatsFuns

struct BetaAtoll{T1<:Real,T2<:Real} <: ContinuousMultivariateDistribution
    λ::T1
    τ::T2
end

function Distributions.rand(rng::AbstractRNG, d::BetaAtoll) 

    p = rand(Uniform(0.0,1.0))

    if p<d.λ
        r=maximum([0.0,1-rand(Exponential(d.τ))])
    else
        r=rand(Beta(2.0,1.0))
    end
    
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]

end

function Distributions.rand!(rng::AbstractRNG,d::BetaAtoll,x::AbstractArray)
    p = rand(Uniform(0.0,1.0))

    if p<d.λ
        r=maximum([0.0,1-rand(Exponential(d.τ))])
    else
        r=rand(Beta(2.0,1.0))
    end
    
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]

end

function Distributions._rand!(rng::AbstractRNG,d::BetaAtoll,x::AbstractArray) 

    p = rand(Uniform(0.0,1.0))

    if p<d.λ
        r=maximum([0.0,1-rand(Exponential(d.τ))])
    else
        r=rand(Beta(2.0,1.0))
    end
    
    ϕ=rand(Uniform(-π,π))
    [r*cos(ϕ),r*sin(ϕ)]

end

function Distributions.pdf(d::BetaAtoll, x::AbstractArray{<:Real})
    ρ=norm(x)
    if ρ<=0 || ρ>=1
        return zero(ρ)
    else
        return (d.λ*Distributions.pdf(Exponential(1.0),(1-ρ)/d.τ)+(1-d.λ))*inv2π
    end
end

function Distributions.logpdf(d::BetaAtoll, x::AbstractArray{<:Real})
    ρ=norm(x)
    if ρ<=0 || ρ>=1
        return log(zero(ρ))
    else
        return log(pdf(d,x))
    end
end

function Distributions._logpdf(d::BetaAtoll, x::AbstractArray{<:Real})
    ρ=norm(x)
    if ρ<=0 || ρ>=1
        return log(zero(ρ))
    else
        return log(pdf(d,x))
    end
end

Distributions.length(d::BetaAtoll)=2

Distributions.sampler(d::BetaAtoll)=d

Bijectors.bijector(d::BetaAtoll) = Identity{1}()



