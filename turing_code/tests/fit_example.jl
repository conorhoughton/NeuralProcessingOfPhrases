# first go at modelling some data

using DynamicHMC, Turing
using Random
#Random.seed!(0)


include("general.jl")
include("wrapped_cauchy.jl")
include("bundt.jl")


#make a small experiment
participant=5
electrode=5
freqN=58

experiment=load([participant])
experiment=experiment[(experiment.participant.==participant) .& (experiment.electrode.==electrode) .& (experiment.freqC.<=freqN),:]

gammaWidth=15.0

@model function fitWrapped(angles,freqs,nF,::Type{T} = Float64) where {T}
    

    gamma~filldist(Exponential(gammaWidth),nF)

    
    x=Vector{Vector{T}}(undef, nF)
    for i in 1:nF
        x[i]    ~ Bundt()
    end

    for i in 1:length(angles)
        mu=atan(x[freqs[i]][1],x[freqs[i]][2])
        angles[i]~ WrappedCauchy(mu,gamma[freqs[i]])
    end

end

nF=freqN

angles=experiment.angle
freqs =experiment.freqC

epsilon = 0.001
tau = 10
iterations = 1000

chain = sample(fitWrapped(angles,freqs,nF), NUTS(0.6), iterations, progress=true)

    
