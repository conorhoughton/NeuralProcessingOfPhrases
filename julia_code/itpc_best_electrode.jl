 
# quick programme cut from itpc to find which is the best electrode
# define as larges phrase peak

using HypothesisTests
using KernelDensity
using Distributions

include("general.jl")
include("mean_res.jl")
include("confidence.jl")

filename_path="/home/cscjh/Experiment2/data/"
filename_file="file_list_full.txt"

lines=readlines(filename_path*filename_file)

filepath="/home/cscjh/Experiment2/processed_data/ft/"
filename_extra="_ft.dat"
filename_trial="_trial.dat"
freqFile="freq.txt"

participantN=20 # number of participants
frequencyN=58
stimuli=getStimuli()
stimuliP1to4=getStimuliP1to4()
stimuliN=length(stimuli)
trialN=24
electrodeN=32


#----------------- load frequency file

frequencies=Float64[]

open(filepath*freqFile) do file
        for ln in eachline(file)
            if ln!=""
                push!(frequencies,parse(Float64,ln))
            end
        end
end


#------------------ find significant peaks

grammar=getGrammarPeaks()
grammarIndices=Int64[]

for g in grammar
    push!(grammarIndices,findfirst(frequencies.==g))
end


f=grammarIndices[2] # phrase
s="anan"

allITPC=zeros(Float64,participantN,electrodeN)

for (participantI,line) in enumerate(lines)

    global allITPC
    
    nameRoot=strip(line)

    filename=filepath*nameRoot*filename_extra
    
    keyFile=Int64[]
    
    open(filepath*nameRoot*filename_trial) do file
        for ln in eachline(file)
            if ln!=""
                push!(keyFile,parse(Int64,ln))
            end
        end
    end

    #---------load the matrix of Fourier coefficients
    if participantI<5
        condPhase=conditionP1to4(filename,keyFile)
    else
        condPhase=conditionP5to20(filename,keyFile)
    end
            
    #--------normal itpc

    # dispersion=biasCorrect
    dispersion=meanResultant
    #  dispersion=circularVariance
    
    
    bigA=phase(condPhase[s])

    
    allITPC[participantI,:]=dispersion(bigA[2])[:,f]

    
end

println(findmax(dropdims(mean(allITPC,dims=1),dims=1)))

#17 is the answer
