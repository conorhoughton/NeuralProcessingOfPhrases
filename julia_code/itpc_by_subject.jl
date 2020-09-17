

# this programme does the "by item" analysis for comparison with the by subject analysis
# that is it makes "item" (what we call trial) the random variable
# it calculates the ITPC by summing over subjects
# it loads the big matrices of Fourier coefficients
# organizes them into a dictionary that can be used to make matrices and vectors
# it uses these to do the stats
# and output files for plotting


using HypothesisTests
using KernelDensity
using Distributions

include("general.jl")
include("mean_res.jl")
include("confidence.jl")

function mWTest(condHigher::Int64,condLower::Int64,allITPC,frequencyI,p::Float64)
    statTest(MannWhitneyUTest,condHigher,condLower,allITPC,frequencyI,p)
end


function signTest(condHigher::Int64,condLower::Int64,allITPC,frequencyI,p::Float64)
    statTest(SignTest,condHigher,condLower,allITPC,frequencyI,p)
end


function statTest(test,condHigher::Int64,condLower::Int64,allITPC,frequencyI,p::Float64)
    a=allITPC[:,condHigher,frequencyI]
    b=allITPC[:,condLower ,frequencyI]
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
stimuli=getStimuliP1to4()
stimuliN=length(stimuli)
trialN=24
electrodeN=32

allSummand=zeros(Complex,trialN,electrodeN,stimuliN,frequencyN)

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


    for (stimulusI,stimulus) in enumerate(stimuli) 
        bigA=phase(condPhase[stimulus])
        allSummand[:,:,stimulusI,:]+=bigA[2]
    end
    
end


# [trial , stimulus, freq]
allITPC=dropdims(sum(abs.(allSummand)./participantN,dims=2)./electrodeN,dims=2)

#----------------- load frequency file

frequencies=Float64[]

open(filepath*freqFile) do file
        for ln in eachline(file)
            if ln!=""
                push!(frequencies,parse(Float64,ln))
            end
        end
end

# remember the stimuli are only avav anan and phmi


#### this is a bit of a mess, it is a long list of things only used
#### once and are written as a series of functions with global variables


#--------------- print ICTP grand average

function printGrandAverage(stimulusI)

    stimulusI=3
    
    grandAverage=dropdims(sum(allITPC,dims=1),dims=1)/trialN

    for f in 1:frequencyN
        println(frequencies[f]," ",grandAverage[stimulusI,f])
    end

end

#--------------- print ICTP - all

#this hasn't be undated

function printAll(stimulusI)

    for f in 1:frequencyN
        print(frequencies[f]," ")
        for trialI in 1:trialN
            print(allITPC[trialI,stimulusI,f]," ")
        end
        print("\n")
    end

end


#------------------ locate  peaks

grammar=getGrammarPeaks()
grammarIndices=Int64[]

for g in grammar
    push!(grammarIndices,findfirst(frequencies.==g))
end

# ---------------------- find significant peaks

function findSignificantPeaks(pointN)
    
    nullITPC=randomITPC(pointN,participantN,electrodeN)

    f=grammarIndices[1]
    
    println("sentence")
    print("avav ")
    println(pvalue(MannWhitneyUTest(allITPC[:,1,f],nullITPC),tail=:right))
    print("anan ")
    println(pvalue(MannWhitneyUTest(allITPC[:,2,f],nullITPC),tail=:right))
    print("phmi ")
    println(pvalue(MannWhitneyUTest(allITPC[:,3,f],nullITPC),tail=:right))

    
    f=grammarIndices[2]
    
    println("\nphrase")
    print("avav ")
    println(pvalue(MannWhitneyUTest(allITPC[:,1,f],nullITPC),tail=:right))
    print("anan ")
    println(pvalue(MannWhitneyUTest(allITPC[:,2,f],nullITPC),tail=:right))
    print("phmi ")
    println(pvalue(MannWhitneyUTest(allITPC[:,3,f],nullITPC),tail=:right))

    f=grammarIndices[4]
    
    println("\nsyllable")
    print("avav ")
    println(pvalue(MannWhitneyUTest(allITPC[:,1,f],nullITPC),tail=:right))
    print("anan ")
    println(pvalue(MannWhitneyUTest(allITPC[:,2,f],nullITPC),tail=:right))
    print("phmi ")
    println(pvalue(MannWhitneyUTest(allITPC[:,3,f],nullITPC),tail=:right))

end



# ---------------------- compare phrase peaks 


function comparePhrasePeaks()

    f=grammarIndices[2]

    testVectors=Dict("avav"=>allITPC[:,1,f],"anan"=>allITPC[:,2,f],"phmi"=>allITPC[:,3,f])


    println("\nmeans")
    for stimulus in stimuli
        println(stimulus," ",mean(testVectors[stimulus]))
    end
    
    
    println("\npairwise")

    for i in 1:3
        for j in i+1:3
            print(stimuli[i]," v ",stimuli[j]," ")
            println( pvalue(SignTest(testVectors[stimuli[i]],testVectors[stimuli[j]]),tail=:both))
        end
    end

    println("\nKruskalWallis")
    println(pvalue(KruskalWallisTest(testVectors["avav"],testVectors["anan"],testVectors["phmi"])))
    
end


# ---------- int main()

#printGrandAverage(5)
#printAll(5)
findSignificantPeaks(10_000)
comparePhrasePeaks()

