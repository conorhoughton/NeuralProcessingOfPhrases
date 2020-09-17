
# this looks at the per participant results using a bootstrap
# it produces weird results, maybe because bootstrap doesn't deal
# well with outliers

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


bootstrapN=100

# load frequencies

frequencies=Float64[]

open(filepath*freqFile) do file
        for ln in eachline(file)
            if ln!=""
                push!(frequencies,parse(Float64,ln))
            end
        end
end


grammar=getGrammarPeaks()
grammarIndices=Int64[]

for g in grammar
    push!(grammarIndices,findfirst(frequencies.==g))
end

freqIndex=grammarIndices[2] # phrases

allITPC=zeros(Float64,participantN,stimuliN,bootstrapN)

realITPC=zeros(Float64,participantN,stimuliN)

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
    
    dispersion=meanResultant
    
    if participantI<5
        for (stimulusI,stimulus) in enumerate(stimuliP1to4) 
            bigA=phase(condPhase[stimulus])
            thisPhase=bigA[2][:,:,freqIndex]
            realITPC[participantI,stimulusI+3]=mean(dispersion(thisPhase))
            for bootstrapC in 1:bootstrapN
                phases=zeros(Complex{Float64},trialN,electrodeN)
                for trialC in 1:trialN
                    thisTrial=rand(1:trialN)
                    phases[trialC,:]=bigA[2][thisTrial,:,freqIndex]
                end
                this_dispersion=mean(dispersion(phases))
                allITPC[participantI,stimulusI+3,bootstrapC]=this_dispersion
            end
        end
    else 
        for (stimulusI,stimulus) in enumerate(stimuli) 
            bigA=phase(condPhase[stimulus])
            thisPhase=bigA[2][:,:,freqIndex]
            realITPC[participantI,stimulusI]=mean(dispersion(thisPhase))
            for bootstrapC in 1:bootstrapN
                phases=zeros(Complex{Float64},trialN,electrodeN)
                for trialC in 1:trialN
                    thisTrial=rand(1:trialN)
                    phases[trialC,:]=bigA[2][thisTrial,:,freqIndex]                    
                end
                this_dispersion=mean(dispersion(phases))
                allITPC[participantI,stimulusI,bootstrapC]=this_dispersion
            end
        end
    end


    
end


# ------------- significance of peaks per participant

function participantPeaks()

    ourStimuli=[2,4,5,6]

    pointN=100

    nullITPC=randomITPC(pointN,trialN,electrodeN)

    rrrr=Float64[]
    avav=Float64[]
    anan=Float64[]
    phmi=Float64[]
    
    for participantC in 5:20
        push!(rrrr,pvalue(MannWhitneyUTest(allITPC[participantC,2,:],nullITPC),tail=:right))
    end

    for participantC in 1:20
        push!(avav,pvalue(MannWhitneyUTest(allITPC[participantC,4,:],nullITPC),tail=:right))
        push!(anan,pvalue(MannWhitneyUTest(allITPC[participantC,5,:],nullITPC),tail=:right))
        push!(phmi,pvalue(MannWhitneyUTest(allITPC[participantC,6,:],nullITPC),tail=:right))
    end

    
    for s in 4:6
        println(s)
        println(mean(allITPC[5,s,:]))
        println(realITPC[5,s])
    end
    
    # println("MW")
    # println("rrrr ",length(findall(rrrr.>0.05)))
    # println("avav ",length(findall(avav.>0.05)))
    # println("anan ",length(findall(anan.>0.05)))
    # println("phmi ",length(findall(phmi.>0.05)))

    # meanNull=mean(nullITPC)
    
    # println("means")
    # println("rrrr ",length(findall(mean(allITPC[5:20,2,:],dims=2).>meanNull)))
    # println("avav ",length(findall(mean(allITPC[:,4,:],dims=2).>meanNull)))
    # println("anan ",length(findall(mean(allITPC[:,5,:],dims=2).>meanNull)))
    # println("phmi ",length(findall(mean(allITPC[:,6,:],dims=2).>meanNull)))


    # for p in 1:participantN
    #     println(realITPC[p,5]," ",mean(allITPC[p,5,:]))
    # end

    
    
end

participantPeaks()




