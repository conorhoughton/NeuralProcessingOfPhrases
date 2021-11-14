
# prints out the length and angle of the resultant for participants
# and electrodes for a give condition

using HypothesisTests

include("general.jl")
include("mean_res.jl")

filename_path="../data/ft/"
filename_file="file_list_16.txt"

lines=readlines(filename_path*filename_file)

filepath="../data/ft/"
filename_extra="_ft.dat"
filename_trial="_trial.dat"
freqFile="freq.txt"

participantN=16 # number of participants
frequencyN=58
electrodeN=32
stimuli=getStimuli()
stimuliN=length(stimuli)

frequencies=Float64[]

open(filepath*freqFile) do file
        for ln in eachline(file)
            if ln!=""
                push!(frequencies,parse(Float64,ln))
            end
        end
    end

grammar =getGrammarPeaks()
freqI=findfirst(frequencies.==grammar[2])

for (participantI,line) in enumerate(lines)

    global itpc

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
    
    condPhase=conditionP5to20(filename,keyFile)

    stimulus="anan"

    
    bigA=phase(condPhase[stimulus])

    circular=circularMeasures(bigA[2][:,:,freqI])

    # r=meanResultant(bigA[2][:,:,freqI])
    # rSorted=sort(r,rev=true)[1:5]

    # max_ind=findall(x -> x in rSorted,r)

    # println(max_ind)
    
    #for simplicity use a loop
    for electrodeI in 1:electrodeN
        print(participantI," ",electrodeI," ")
        println(circular[1][electrodeI]," ",circular[2][electrodeI])
    end

end
