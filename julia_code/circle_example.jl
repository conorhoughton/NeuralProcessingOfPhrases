

# hacked from itpc.jl to give some phase for circle plot examples for a talk

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

stimulus=5
frequency=grammarIndices[2]

allPhase=zeros(Complex{Float64},participantN,trialN,electrodeN)

for (participantI,line) in enumerate(lines)

    global allPhase
    
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
    

    bigA=phase(condPhase[stimuli[stimulus]])
            
    allPhase[participantI,:,:]=bigA[2][:,:,frequency]



    
end



#participant=15
participant=8
electrode=10

for i in 1:trialN
    z=allPhase[participant,i,electrode]
    println(real(z)," ",imag(z))
end

println(mean(allPhase[participant,:,electrode]))


#println(confidenceInterval(10_000,24,1,0.05))

  
