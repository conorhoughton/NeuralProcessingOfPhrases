
#https://github.com/ziotom78/CorrNoise.jl

using Random
using CorrNoise
using Statistics

rng = OofRNG(GaussRNG(MersenneTwister(1234)), -1.0, 1.15e-5, 0.05, 1000.0);
data = [randoof(rng) for i in 1:100000]
#plot(data)

println(std(data)," ",mean(data))

#for i in 1:1000
#    println(randoof(rng))
#end
