

# this is the programme that does all the work
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
stimuli=getStimuli()
stimuliP1to4=getStimuliP1to4()
stimuliN=length(stimuli)
trialN=24
electrodeN=32

allITPC=zeros(Float64,participantN,stimuliN,frequencyN)

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
    
    if participantI<5
        for (stimulusI,stimulus) in enumerate(stimuliP1to4) 
            bigA=phase(condPhase[stimulus])
            allITPC[participantI,stimulusI+3,:]=dropdims(sum(dispersion(bigA[2]),dims=1)/size(bigA[2])[2],dims=1)
        end
    else 
        for (stimulusI,stimulus) in enumerate(stimuli) 
            bigA=phase(condPhase[stimulus])
            allITPC[participantI,stimulusI,:]=dropdims(sum(dispersion(bigA[2]),dims=1)/size(bigA[2])[2],dims=1)
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


#### this is a bit of a mess, it is a long list of things only used
#### once and is given as a series of functions with global variables
#### yuck





#--------------- print ICTP grand average

function printGrandAverage(stimulusI)

    if stimulusI>3
        participant0=1
    else
        participant0=5
    end
    
    grandAverage=dropdims(sum(allITPC,dims=1),dims=1)/(participantN-participant0+1)

    for f in 1:frequencyN
        println(frequencies[f]," ",grandAverage[stimulusI,f])
    end

end

#--------------- print ICTP - all

function printAll(stimulusI)

    
    if stimulusI>3
        participant0=1
    else
        participant0=5
    end

    
    for f in 1:frequencyN
        print(frequencies[f]," ")
        for participantI in participant0:participantN
            print(allITPC[participantI,stimulusI,f]," ")
        end
        print("\n")
    end

end


#------------------ find significant peaks

grammar=getGrammarPeaks()
grammarIndices=Int64[]

for g in grammar
    push!(grammarIndices,findfirst(frequencies.==g))
end

#println(grammarIndices)

#----------------- examine the behaviour with the null ITPC vector

function testCompareToNull()

    #stimulusI=6
    
    # for pointsN in 1000:1000:30000
    
    #     nullITPC=randomITPC(pointsN,trialN,1)

    #     print(pointsN," ")
    #     for g in grammarIndices
    #         p=pvalue(MannWhitneyUTest(allITPC[:,stimulusI,g],nullITPC),tail=:right)
    #         print(" ",p)
    #     end
    #     print("\n")
    # end


    pointsN=5000

    nullITPC=randomITPC(pointsN,trialN,1)
    
    for f in 1:frequencyN
        print(f,"  ",frequencies[f])
        for s in 4:6
            p=pvalue(MannWhitneyUTest(allITPC[:,s,f],nullITPC),tail=:right)
            print(" ",p)
        end
        print("\n")
    end
end

# ---------------------- find significant peaks

function findSignificantPeaks(pointN)
    

    nullITPC=randomITPC(pointN,trialN,electrodeN)

    f=grammarIndices[1]
    
    println("sentence")
    print("advp ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,1,f],nullITPC),tail=:right))
    print("rrrr ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,2,f],nullITPC),tail=:right))
    print("rrrv ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,3,f],nullITPC),tail=:right))
    print("avav ")
    println(pvalue(MannWhitneyUTest(allITPC[:,4,f],nullITPC),tail=:right))
    print("anan ")
    println(pvalue(MannWhitneyUTest(allITPC[:,5,f],nullITPC),tail=:right))
    print("phmi ")
    println(pvalue(MannWhitneyUTest(allITPC[:,6,f],nullITPC),tail=:right))

    
    f=grammarIndices[2]
    
    println("\nphrase")
    print("rrrr ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,2,f],nullITPC),tail=:right))
    print("avav ")
    println(pvalue(MannWhitneyUTest(allITPC[:,4,f],nullITPC),tail=:right))
    print("anan ")
    println(pvalue(MannWhitneyUTest(allITPC[:,5,f],nullITPC),tail=:right))
    print("phmi ")
    println(pvalue(MannWhitneyUTest(allITPC[:,6,f],nullITPC),tail=:right))

    f=grammarIndices[4]
    
    println("\nsyllable")
    print("rrrr ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,2,f],nullITPC),tail=:right))
    print("avav ")
    println(pvalue(MannWhitneyUTest(allITPC[:,4,f],nullITPC),tail=:right))
    print("anan ")
    println(pvalue(MannWhitneyUTest(allITPC[:,5,f],nullITPC),tail=:right))
    print("phmi ")
    println(pvalue(MannWhitneyUTest(allITPC[:,6,f],nullITPC),tail=:right))

end


# ---------------------- find significant peaks 16
### same again using only P5-20

function findSignificantPeaks16(pointN)

    println("P5-16 only")
    

    nullITPC=randomITPC(pointN,trialN,electrodeN)

    
    f=grammarIndices[1]
    
    println("sentence")
    print("advp ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,1,f],nullITPC),tail=:right))
    print("rrrr ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,2,f],nullITPC),tail=:right))
    print("rrrv ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,3,f],nullITPC),tail=:right))
    print("avav ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,4,f],nullITPC),tail=:right))
    print("anan ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,5,f],nullITPC),tail=:right))
    print("phmi ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,6,f],nullITPC),tail=:right))

    
    f=grammarIndices[2]
    
    println("\nphrase")
    print("advp ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,1,f],nullITPC),tail=:right))
    print("rrrr ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,2,f],nullITPC),tail=:right))
    print("rrrv ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,3,f],nullITPC),tail=:right))
    print("avav ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,4,f],nullITPC),tail=:right))
    print("anan ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,5,f],nullITPC),tail=:right))
    print("phmi ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,6,f],nullITPC),tail=:right))

    f=grammarIndices[4]
    
    println("\nsyllable")
        print("advp ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,1,f],nullITPC),tail=:right))
    print("rrrr ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,2,f],nullITPC),tail=:right))
    print("rrrv ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,3,f],nullITPC),tail=:right))
    print("avav ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,4,f],nullITPC),tail=:right))
    print("anan ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,5,f],nullITPC),tail=:right))
    print("phmi ")
    println(pvalue(MannWhitneyUTest(allITPC[5:20,6,f],nullITPC),tail=:right))

end



# ---------------------- compare phrase peaks 


function comparePhrasePeaks()

    ourStimuli=stimuli[[2,4,5,6]]

    f=grammarIndices[2]

    testVectors=Dict("rrrr"=>allITPC[5:20,2,f],"avav"=>allITPC[:,4,f],"anan"=>allITPC[:,5,f],"phmi"=>allITPC[:,6,f])


    println("\nmeans")
    for stimulus in ourStimuli
        println(stimulus," ",mean(testVectors[stimulus]))
    end
    
    
    println("\npairwise")

    for i in 1:4
        for j in i+1:4
            print(ourStimuli[i]," v ",ourStimuli[j]," ")
            if i==1
                println( pvalue(SignTest(testVectors[ourStimuli[i]],testVectors[ourStimuli[j]][5:20]),tail=:both))
            else
                println( pvalue(SignTest(testVectors[ourStimuli[i]],testVectors[ourStimuli[j]]),tail=:both))
            end
       end
    end

    println("\nKruskalWallis")
    println(pvalue(KruskalWallisTest(testVectors["rrrr"],testVectors["avav"],testVectors["anan"],testVectors["phmi"])))
    
end

# ---------------------------------------- like compare phrase peaks but for syllables

function compareSyllablePeaks()

    println("compare syllable peaks")
    
    ourStimuli=stimuli[[2,4,5,6]]

    f=grammarIndices[4]

    testVectors=Dict("rrrr"=>allITPC[5:20,2,f],"avav"=>allITPC[:,4,f],"anan"=>allITPC[:,5,f],"phmi"=>allITPC[:,6,f])


    println("\nmeans")
    for stimulus in ourStimuli
        println(stimulus," ",mean(testVectors[stimulus]))
    end
    
    
    println("\npairwise")

    for i in 1:4
        for j in i+1:4
            print(ourStimuli[i]," v ",ourStimuli[j]," ")
            if i==1
                println( pvalue(SignTest(testVectors[ourStimuli[i]],testVectors[ourStimuli[j]][5:20]),tail=:both))
            else
                println( pvalue(SignTest(testVectors[ourStimuli[i]],testVectors[ourStimuli[j]]),tail=:both))
            end
        end
    end

    println("\nKruskalWallis")
    println(pvalue(KruskalWallisTest(testVectors["rrrr"],testVectors["avav"],testVectors["anan"],testVectors["phmi"])))
    
end


# ---------------------- compare phrase peaks 16
# same analysis again but only using P5-20 and for the other stimuli

function comparePhrasePeaks16OtherStim()

    
    
    println("\nP5-16 only")

    println("ADVP / RRRV / ANAN")
    
    ourStimuli=stimuli[[1,3,5]]

    f=grammarIndices[2]

    println("f=",f)
    
    testVectors=Dict("rrrv"=>allITPC[5:20,3,f],"advp"=>allITPC[5:20,1,f],"anan"=>allITPC[5:20,5,f])

#    println(testVectors)

    println("\nmeans")
    for stimulus in ourStimuli
        println(stimulus," ",mean(testVectors[stimulus]))
    end
    
    println("\npairwise")

    for i in 1:16
        println(testVectors[ourStimuli[1]][i]," ",testVectors[ourStimuli[3]][i])
    end
    
    for i in 1:3
        for j in i+1:3
            print(ourStimuli[j]," v ",ourStimuli[i]," ")
            println(pvalue(OneSampleTTest(testVectors[ourStimuli[j]],testVectors[ourStimuli[i]]),tail=:both))
        end
    end

    println("\nKruskalWallis")
    println(pvalue(KruskalWallisTest(testVectors["rrrv"],testVectors["advp"],testVectors["anan"])))
    
end


# ------------ kde for ITCP values

function kernelDensity()
    
    f=grammarIndices[2]
    s1=5
    s2=4

    samples=allITPC[:,s1,f].-allITPC[:,s2,f]
    
    u=kde(samples)

    d=fit(Normal,samples)
    
    for i in 1:length(u.x)
        println(u.x[i]," ",u.density[i]," ",pdf(d,u.x[i]))
    end
    
end

# ------------- t test
### P5-20 only for simplicity

function tTest()

    println("\nt test --- P5-16 only")
    
    ourStimuli=stimuli[[2,4,5,6]]
    
    f=grammarIndices[2]

    testVectors=Dict("rrrr"=>allITPC[5:20,2,f],"avav"=>allITPC[5:20,4,f],"anan"=>allITPC[5:20,5,f],"phmi"=>allITPC[5:20,6,f])

    
    println("\npairwise")

    for i in 1:4
        for j in i+1:4
            print(ourStimuli[i]," v ",ourStimuli[j]," ")
            println( pvalue(OneSampleTTest(testVectors[ourStimuli[i]],testVectors[ourStimuli[j]]),tail=:both))
        end
    end
    
end


# ------------- significance of peaks per participant

function participantPeaks()

    ourStimuli=[2,4,5,6]
    
    trialN=24
    participantN=1
    electrodeN=32
    pointN=10_000
    confidence=0.05
    
    interval=confidenceInterval(pointN,trialN,electrodeN,confidence)
    intervalI=1
    
    println("\ninterval")
    
    println(interval)

    println("\nphrases")
    
    for s in ourStimuli
        println(stimuli[s]," ",length(findall(allITPC[:,s,grammarIndices[2]].>interval[1])))
    end

    println("\nsylables")
        
    for s in ourStimuli
        println(stimuli[s]," ",length(findall(allITPC[:,s,grammarIndices[4]].>interval[1])))
    end

end

# ---------------- data for individual participant figure

function individuals()
    

    ourStimuli=[2,4,5,6]
    
    trialN=24

    electrodeN=32
    pointN=10_000
    confidence=0.05
    
    interval=confidenceInterval(pointN,trialN,electrodeN,confidence)
    
#    println("\ninterval")
    
#    println(interval)
    
    participantN=20
    
    s=5 # ANAN
    g=grammarIndices[2] #phrase

    data=Array{Tuple{Int64,Float64}}(undef,participantN)
    
    
    for i in 1:participantN
        data[i]=(i,allITPC[i,s,g])
    end

    order=[x[1] for x in sort(data, by = x->x[2])]

    s=6
 
    for o in order
        if s!=2 || (s==2 && o>4)
            for g in grammarIndices[[2,4]]
                print(allITPC[o,s,g]," ",allITPC[o,s,g]>interval[2]," ")
            end
            println()     
        else
            println(0.0," ",false," ",0.0," ",false)
        end
    end
        
end


# ---------------- prints the order of participants by ANAN phrase response

function whoIsTheBest()
    

    s=5 # ANAN
    g=grammarIndices[2] #phrase

    data=Array{Tuple{Int64,Float64}}(undef,participantN)
    
    
    for i in 1:participantN
        data[i]=(i,allITPC[i,s,g])
    end

    order=[x[1] for x in sort(data, by = x->x[2])]

    println(order)
        
end

    

    

#---------------- int main()

#printGrandAverage(3)
#printAll(3)
#findSignificantPeaks(10_000)
#findSignificantPeaks16(10_000)
#comparePhrasePeaks()
#compareSyllablePeaks()
#comparePhrasePeaks16()
comparePhrasePeaks16OtherStim()
#kernelDensity()
#tTest()
#participantPeaks()

#whoIsTheBest()
