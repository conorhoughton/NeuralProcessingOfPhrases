# first go at modelling the data

using Turing, Distributions
using Random
Random.seed!(0)


include("general.jl")

experiment=load()

#make a small experiment
participant=5
electrode=1

experiment=experiment[experiment.participant.==participant .& experiment.electrode.==electrode,:]

@model function fitWrapped(angle)

    sigma ~ Exponential(10.0)
    mu ~ Uniform(-pi,pi)

    y ~ Normal(mu,sigma)
    angle = y

end
    

    
