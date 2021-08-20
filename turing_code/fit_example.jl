# first go at modelling some data

using DynamicHMC, Turing
using Random
#Random.seed!(0)


include("general.jl")
include("wrapped_cauchy.jl")



#make a small experiment
participant=5
electrode=5
freqN=58

experiment=load([participant])
experiment=experiment[(experiment.participant.==participant) .& (experiment.electrode.==electrode) .& (experiment.freqC.<=freqN),:]


@model function fitWrapped(angles,freqs,nF)
    
    mu=zeros(Real,nF)
    gamma=zeros(Real,nF)

    for i in 1:nF
        gamma[i] ~ Exponential(15.0)
        mu[i]    ~ Uniform(-pi,pi)
    end

    for i in 1:length(angles)
        angles[i]~ WrappedCauchy(mu[freqs[i]],gamma[freqs[i]])
    end

end

nF=freqN
angles=experiment.angle
freqs =experiment.freqC

epsilon = 0.001
tau = 10
iterations = 1000

chain = sample(fitWrapped(angles,freqs,nF), NUTS(0.6), iterations, progress=true)

    
