using Distributions

struct NewSampler <: ContinuousUnivariateDistribution
    mu::Real
    sigma::Real
#    NewSampler(mu, sigma) = new(Float64(mu), Float64(sigma))
end



function Base.rand(d::NewSampler)
    rand(Normal(d.mu,2*d.sigma))
end

Distributions.rand(d::NewSampler) = rand(d) 
Distributions.logpdf(d::NewSampler, x::Real) = logpdf(Normal(d.mu, 2*d.sigma), x)
