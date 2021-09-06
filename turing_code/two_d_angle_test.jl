# first toy example

using Turing, Distributions
using Random
using LinearAlgebra
#Random.seed!(0)

function getAngle(v::Vector{Float64})
    atan(v[1],v[2])
end

cMatrix=Matrix(1.0I,(2,2))
mVector=zeros(Float64,2)

nS=3
twoDData=rand(MvNormal(mVector,cMatrix),nS)
println(twoDData)
println(twoDData[1,:])
println(twoDData[2,:])
atan.(twoDData[1,:],twoDData[2,:])


    
