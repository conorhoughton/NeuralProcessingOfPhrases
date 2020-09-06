
# this makes the fictive eeg based on the word2vec vectors
# a lot of it is book keeping
# it loads files "rrrr.txt" and similar
# that list the trials, in the trial files
# there are lists of words, it then finds the corresponding
# Frank vectors

# the Frank vectors are 300 long so 32 components are picked
# to act as "electrodes"

# it is all hacked a bit but there are two main functions

# simpleCoeff performs a FT specifically on the words and gives the result

# makeResponse makes a big matrix of simulated EEG signals
# this can be saves and run through the get_FT.m matlab code to give the FT
# as performed on the real data

# there are a big variety of different noises and filters for the word -> eeg
# simulation, but the ones we used in the end mimicked the ones in Frank and Yang


using Statistics
using Random
using StatsBase
using FFTW
using MAT
using CorrNoise

keyDictionaryLocation="./keyDictionary/"::String
trialLocation="./trials/"::String
vectorLocation="./vectors/"::String

function getConditionFiles()

    Dict{String,String}("rrrr"=>"rrrr_","avav"=>"AVAV_","anan"=>"ANAN_","phmi"=>"phrase_mix_")

end
    
function loadKeyDictionary()
    fileNamesFile=keyDictionaryLocation*"file_names.txt"

    fileNames=String[]
    
    open(fileNamesFile) do file
        for line in eachline(file)
            if strip(line) != ""
                push!(fileNames,strip(line))
            end
        end
    end

    keys=Dict()

    for fileName in fileNames
        fullFileName=keyDictionaryLocation*fileName*".txt"
        open(fullFileName) do file
            for (i,line) in enumerate(eachline(file))
                if strip(line) !=""
                    keys[strip(line)]=[i,fileName]
                end
            end
        end
    end
    
    keys
    
end

function loadTrial(fileName::String)

    trial=String[]
    fullFileName=trialLocation*fileName

    open(fullFileName) do file
        for line in eachline(file)
                if strip(line) !=""
                    push!(trial,strip(line))
                end
        end
    end

    trial

end


function loadTrialShuffled(fileName::String)

    trial=loadTrial(fileName)
    shuffle(trial)

end


function loadTrial(filename::String,keys,shuffled)

    trial=String[]
    
    if shuffled
        trial=loadTrialShuffled(filename)
    else
        trial=loadTrial(filename)
    end
    
    trialLocation=[]

    for word in trial
        location=get(keys,word,"f/p")
        if location == "f/p"
            println(word," not a word not in keys f/p")
        end
        push!(trialLocation,location)
    end

    trialLocation

end

function loadVector(name::String,lineNumber::Int64)

    fullFileName=vectorLocation*name*".txt"

    foundLine=false

    frankVector=Float64[]
    
    open(fullFileName) do file
        for (i,line) in enumerate(eachline(file))
            if i==lineNumber
                if strip(line) !=""
                    foundLine=true
                    frankVector=[parse(Float64,x) for x in split(line,",")]
                end
            end
        end
    end

    if !foundLine
        println("f/p line not found in ",name)
    end

    frankVector
    
end

function makeTrialResponse(repeatN::Int64,trialName::String,keys,electrodes::Vector{Int64},word0,delay0,delay1,shuffled)

    # function filter(i)
    #     x=2*pi*(i-repeatN/2)/repeatN
    #     if x!=0
    #         sin(x)/x
    #     else
    #         1.0
    #     end
    # end

    #function filter(i)
    #    sin(pi*i/repeatN)
    #end

    # function filter(i)
    #     1.0
    # end


    function filter(i::Int64,delay::Int64)
        if i<delay
            0.0::Float64
        else
            1.0::Float64
        end
    end

    
    # function filter(i::Int64)
    #     x=(i-repeatN/2)/repeatN
    #     exp(-x^2)
    # end


    delay=rand(collect(delay0:delay1))
    
    trial=loadTrial(trialName,keys,shuffled)
    trialN=length(trial)-word0

    electrodeN=length(electrodes)

    response=zeros(Float64,electrodeN,trialN*repeatN)

    for (wordC,word) in enumerate(trial)
        if wordC > word0
            thisVector=loadVector(word[2],word[1])            
            for repeatC in 1:repeatN
                for (i,e) in enumerate(electrodes)
                    response[i,(wordC-1-word0)*repeatN+repeatC]=thisVector[e]*filter(repeatC,delay)
                end
            end
        end
    end

    response

end


function loadTrials(condition::String)

    conditionFiles=getConditionFiles()
    
    fileName=condition*".txt"
    
    trials=String[]
    
    open(fileName) do file
        for line in eachline(file)
            if strip(line) !=""
                trialNumber=strip(split(line)[1])
                trialName=conditionFiles[condition]*trialNumber*".txt"
                push!(trials,trialName)
            end
        end
    end

    trials

end
    
# this was used to do the Fourier transform directly; I changed to exporting the responses
# and running them through the same Fourier code as the real data
# this is just for consistiency 
# the answer is largely unchanged, the peaks are broader from Fieldtrip because of the taper
# anyway since I haven't been using this it probably doesn't work anymore since I started
# adding the noise.

function makeFourierResponse(repeatN::Int64,condition::String,keys,electrodes::Vector{Int64},freqN,freq0,word0,eta)

    freq1=freq0+freqN-1

    trials=loadTrials(condition)

    trialN=length(trials)
    
    bigA=zeros(Complex{Float64},electrodeN,trialN,freqN)

    for (trialC,trialName) in enumerate(trials)
        littleA=makeTrialResponse(repeatN,trialName,keys,electrodes,word0)        
        littleA=littleA.+eta*randn(size(littleA))
        bigA[:,trialC,:]=fft(littleA,2)[:,freq0:freq1]
    end

    bigA
    
end

#note that response has the indicies in a different order to fourierResponse!
#should fix this!

function makeResponse(repeatN::Int64,condition::String,keys,electrodes::Vector{Int64},word0,eta,delay0,delay1,shuffled)

    trials=loadTrials(condition)

    exampleTrial=loadTrial(trials[1],keys,shuffled)
    wordN=length(exampleTrial)-word0

    electrodeN=length(electrodes)
    
    trialN=length(trials)
    
    response=zeros(Float64,trialN,electrodeN,repeatN*wordN)

    for (trialC,trialName) in enumerate(trials)
        pinkNoise=OofRNG(GaussRNG(MersenneTwister(rand(UInt64))), -0.75, 1.15e-5, 0.01, 1000.0)
        trialResponse=makeTrialResponse(repeatN,trialName,keys,electrodes,word0,delay0,delay1,shuffled)
        response[trialC,:,:]=trialResponse
        for t in 1:repeatN*wordN
            r=randoof(pinkNoise)
            for e in 1:electrodeN
                response[trialC,e,t]+=eta*r
            end
        end
    end

    response
    
end

function simpleCoeff(condition::String,keys,electrodes::Vector{Int64},word0)

    a=0.3411 #this is the magic number that gives a uniformly selected x the same std as the word coeffs

    sigma=0.1969 # I now realise it's normal
    
    trials=loadTrials(condition)

    electrodeN=length(electrodes)

    coeff=zeros(Float64,electrodeN)

    for (trialC,trialName) in enumerate(trials)
        
        trial=loadTrial(trialName,keys,false)

        trialCoeff=zeros(Float64,electrodeN)
        
        for (wordC,word) in enumerate(trial)
            if wordC > word0
                thisVector=loadVector(word[2],word[1])
                #thisVector=2*a*rand(Float64,electrodeN)-a*ones(Float64,electrodeN)
                #thisVector=sigma*randn(Float64,electrodeN)
                trialCoeff+=thisVector*(-1)^wordC
            end
        end
        coeff+=abs.(trialCoeff)
        
    end

    sum(abs.(coeff))
    
end

    


function phase(bigA)

    phases=bigA./(abs.(bigA))
    phases

end


function meanResultant(a)
    dropdims(abs.(sum(a,dims=2)./size(a)[2]),dims=2)
end


function electrodeVector(frankN::Int64, electrodeN::Int64)
    sample(collect(1:frankN),electrodeN;replace=false, ordered=true)
end


keys=loadKeyDictionary()

electrodeN=32
frankN=300
word0=4
repeatN=320
wordN=48
trialN=24

condition="rrrr"
shuffled=true # this should be false except to get the true random rrrr

eta=0.5

delay0=20
delay1=60

participantN=20



for participantC in 1:participantN
    println(condition," ",participantC)
    electrodes=electrodeVector(frankN,electrodeN)
    response=makeResponse(repeatN,condition,keys,electrodes,4,eta,delay0,delay1,shuffled)
    
    file = matopen("./simulated_data/"*condition*"_"*string(participantC,pad=2)*"_response.mat", "w")
    #file = matopen("random"*"_response.mat", "w")
    write(file, "response", response)
    close(file)
    

end




#testN=10
#test=Float64[]
#for i in 1:testN
#   push!(test,simpleCoeff(condition,keys,collect(1:300),word0))
#end

#println(mean(test)," ",std(test))

#sort!(test)

#println(test[Int64(0.95*testN)]," ",test[Int64(0.05*testN)])

# conditions=["rrrr","avav","phmi","anan"]

# for condition in conditions
#     println(condition," ",simpleCoeff(condition,keys,collect(1:300),word0))
# end


# condition="rrrr"

# testN=1000
# coeffs=zeros(Float64,testN)

# for testC in 1:testN
#     coeffs[testC]=simpleCoeff(condition,keys,collect(1:300),word0)
# end

# println(mean(coeffs))
# sort!(coeffs)
# println(coeffs[Int64(0.05*testN)]," ",coeffs[Int64(0.95*testN)])

