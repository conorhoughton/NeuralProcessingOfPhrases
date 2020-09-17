

# hacked from itpc.jl to give some power plots for a talk figure

using HypothesisTests
using KernelDensity
using Distributions

include("general.jl")
include("mean_res.jl")
include("confidence.jl")

function mWTest(condHigher::Int64,condLower::Int64,allPower,frequencyI,p::Float64)
    statTest(MannWhitneyUTest,condHigher,condLower,allPower,frequencyI,p)
end


function signTest(condHigher::Int64,condLower::Int64,allPower,frequencyI,p::Float64)
    statTest(SignTest,condHigher,condLower,allPower,frequencyI,p)
end


function statTest(test,condHigher::Int64,condLower::Int64,allPower,frequencyI,p::Float64)
    a=allPower[:,condHigher,frequencyI]
    b=allPower[:,condLower ,frequencyI]
    this_p=pvalue(test(a,b),tail=:right)
    if this_p<p
        (true,this_p)
    else
        (false,this_p)
    end
    
end

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

allPower=zeros(Float64,participantN,stimuliN,frequencyN)

for (participantI,line) in enumerate(lines)

    global allPower
    
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
    dispersion=getPower
    #  dispersion=circularVariance
    
    if participantI<5
        for (stimulusI,stimulus) in enumerate(stimuliP1to4) 
            bigA=condPhase[stimulus]
            allPower[participantI,stimulusI+3,:]=dropdims(sum(dispersion(bigA[2]),dims=1)/size(bigA[2])[2],dims=1)
        end
    else 
        for (stimulusI,stimulus) in enumerate(stimuli) 
            bigA=condPhase[stimulus]
            allPower[participantI,stimulusI,:]=dropdims(sum(dispersion(bigA[2]),dims=1)/size(bigA[2])[2],dims=1)
        end
    end


    
end


#----------------- load frequency file

frequencies=Float64[]

open(filepath*freqFile) do file
        for ln in eachline(file)
            if ln!=""
                push!(frequencies,parse(Float64,ln))
            end
        end
end



#participant0=5





#--------------- print power grand average

function normalize(stimulusI)

    if stimulusI<4
        println("not a suitable stimulus f/p")
    end

    for p in 1:participantN
        first=allPower[p,stimulusI,1]
        for f in 1:frequencyN
            allPower[p,stimulusI,f]/=first
        end
    end

end


function printGrandAverage(stimulusI)

    normalize(stimulusI)
    
    participant0=5
    
        
    grandAverage=dropdims(sum(allPower[participant0:end,:,:],dims=1),dims=1)/(participantN-participant0+1)

    for f in 1:frequencyN
        println(frequencies[f]," ",grandAverage[stimulusI,f])
    end

end

#--------------- print power - all

function printAll(stimulusI)

    normalize(stimulusI)

    participant0=5
    
    for f in 1:frequencyN
        print(frequencies[f]," ")
        for participantI in participant0:participantN
            print(allPower[participantI,stimulusI,f]," ")
        end
        print("\n")
    end

end


# -------------- int main()

printGrandAverage(5)
#printAll(5)
