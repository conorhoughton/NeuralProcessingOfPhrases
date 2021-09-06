#testing the "atoll" distribution

using Turing, Distributions
using Random
using LinearAlgebra

#Random.seed!(0)

struct Atoll <: ContinuousMultivariateDistribution
end

Distributions.length(d::Atoll)=2
Distributions.pdf(d::Atoll, x::AbstractVector{<:Real}) = 1/4pi * norm(x)*exp(-norm(x))
Distributions.logpdf(d::Atoll, x::AbstractVector{<:Real}) = log(norm(x)) - norm(x)-log(4pi)
Distributions._logpdf(d::Atoll, theta::Real) = log(norm(x)) - norm(x)-log(4pi)
function Distributions.rand(rng::AbstractRNG, d::Atoll) 
    r=rand(Gamma())
    theta=rand(Uniform(-pi,pi))
    [r*cos(theta),r*sin(theta)]
end

function Distributions.rand!(rng::AbstractRNG,d::Atoll,x::AbstractArray) 
    r=rand(Gamma())
    theta=rand(Uniform(-pi,pi))
    x=[r*cos(theta),r*sin(theta)]
end

function Distributions._rand!(rng::AbstractRNG,d::Atoll,x::AbstractArray) 
    r=rand(Gamma())
    theta=rand(Uniform(-pi,pi))
    x=[r*cos(theta),r*sin(theta)]
end

Distributions.sampler(d::Atoll)=d

for i in 1:10
    println(rand(Atoll()))
end

a=Atoll()

println(pdf(a,[0.0,0.0]))

println(pdf(a,[1.0,1.0]))

println(logpdf(a,[1.0,1.0]))
