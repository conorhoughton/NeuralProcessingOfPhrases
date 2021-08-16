#this is a data loading example
#it loads a single ft file as a data frame, works out the itpc and averages it over electrodes

using DataFrames
using CSV
using Statistics

function load(filename::String)

    nElectrodes=32
    nFreq=58

    lines=[]

    open(filename) do file
        for line in eachline(file)
            push!(lines,[parse(Complex{Float64},z) for z in split(line,",")])
        end
    end

    nTrials=length(lines)

    a = zeros(Complex{Float64},(nTrials,nElectrodes,nFreq))

    for i in 1:nTrials
        for j in 1:nElectrodes
            for k in 1:nFreq
                a[i,j,k]=lines[i][nElectrodes*(k-1)+j]
            end
        end
    end

    a

end



rootName = "../data/ft/"

partName = "P10_6_12_2018"

inputFile=rootName*partName*"_ft.dat"
trialFile=rootName*partName*"_trial.dat"

freqFile = rootName*"freq.txt"

frequencies=Float64[]

open(freqFile) do file
        for ln in eachline(file)
            if ln!=""
                push!(frequencies,parse(Float64,ln))
            end
        end
end

bigA=load(inputFile)

trial=DataFrame(CSV.File(trialFile,header=false))

ft=DataFrame(trial=Int64[],electrode=Int64[],freqC=Int32[],freq=Float64[],ft=Complex{Float64}[])

sizeBigA=size(bigA)

for trialC in 1:sizeBigA[1]
    for electrodeC in 1:sizeBigA[2]
        for freqC in 1:sizeBigA[3]
            push!(ft,[trial.Column1[trialC],electrodeC,freqC,frequencies[freqC],bigA[trialC,electrodeC,freqC]])
        end
    end
end

ft[!,:phase]= ft[!,:ft]./abs.(ft[!,:ft])

ftFE=combine(groupby(ft,[:freqC,:electrode]),:phase=>mean=>:meanR)
ftFE[!,:itpc]=abs.(ftFE[!,:meanR])  
ftF=combine(groupby(ftFE,[:freqC]),:itpc=>mean=>:meanItpc)

for f in eachrow(ftF)
    println(f.freqC," ",frequencies[f.freqC]," ",f.meanItpc)
end
