# this loads all the data into a data frame

using DataFrames
using CSV
using Statistics

function getStimuli()
    ["advp","rrrr","rrrv","avav","anan","phmi"]
end

function getStimuliP1to4()
    ["avav","anan","phmi"]
end

function condition(trial)
    getStimuli()[trunc(Int,trial/30)+1]
end
    
function getGrammarPeaks()
    f=1/0.32
    [0.25*f,0.5*f,0.75*f,f]
end

#loads a single participant into a matrix
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

function load()

    experiment=DataFrame(participant=Int64[],name=String[],condition=String[],trial=Int64[],electrode=Int64[],freqC=Int32[],freq=Float64[],ft=Complex{Float64}[],phase=Complex{Float64}[],angle=Float64[])

    pathName = "../data/ft/"
    freqFile = pathName*"freq.txt"

    frequencies=Float64[]

    open(freqFile) do file
        for ln in eachline(file)
            if ln!=""
                push!(frequencies,parse(Float64,ln))
            end
        end
    end

    filenameFile="file_list_full.txt"
    lines=readlines(pathName*filenameFile)

    for (participantI,line) in enumerate(lines)

        nameRoot=strip(line)
        inputFile=pathName*nameRoot*"_ft.dat"
        trialFile=pathName*nameRoot*"_trial.dat"

        println("loading "*nameRoot)
        
        bigA=load(inputFile)

        trial=DataFrame(CSV.File(trialFile,header=false))

        sizeBigA=size(bigA)

        for trialC in 1:sizeBigA[1]
            for electrodeC in 1:sizeBigA[2]
                for freqC in 1:sizeBigA[3]
                    thisFt=bigA[trialC,electrodeC,freqC]
                    trialN=trial.Column1[trialC]
                    push!(experiment,[participantI,nameRoot,condition(trialN),trialN,electrodeC,freqC,frequencies[freqC],thisFt,thisFt/abs(thisFt),angle(thisFt)])
                end
            end
        end

    end

    experiment
    
end
