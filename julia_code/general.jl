
# general helper functions including crucially the load functions
# and condition function which splits trials by condition


# for those of us who distrust global variables
function getStimuli()
    ["advp","rrrr","rrrv","avav","anan","phmi"]
end

function getStimuliP1to4()
    ["avav","anan","phmi"]
end



function getGrammarPeaks()
    f=1/0.32
    [0.25*f,0.5*f,0.75*f,f]
end


# -------------------------
# loading stuff
# -------------------------
# loading from the dat files output by matlab so can deflatten
# also a function to split by condition



# converts tile name into
# [nTrials, a]
# nTrials is the number of trials
# a is
# a matrix of fourier coefficients which are Complex{Float64}'s
# [trial index][electrode index][frequency index]
# the number of electrodes is fixed at 32
# the number of frequencies is fixed at 58
# these can be changed by changing nElectrodes and nFreq

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

#    println(nTrials)
    
    [nTrials,a]

end


function phase(bigA)

    phases=bigA[2]./(abs.(bigA[2]))
    [bigA[1],phases]

end


function  phase(filename::String)

    bigA=load(filename)
    phase(bigA)

end
    
#splits the input into a dictionary of conditions


function condition(phases::Array{Complex{Float64},3},decoding::Vector{Int64},stimuli::Array{String},offset::Int64)

    trialsPerCondition=25::Int64
    stride=30::Int64
    
    condPhases=Dict()
    
    for (i,stimuli) in enumerate(stimuli)
        a=(i-1)*stride+offset
        b=a+trialsPerCondition-1
        condPhases[stimuli]=[trialsPerCondition,phases[findall(x->x in a:b, decoding),:,:]]
    end

    condPhases

end


function conditionP1to4(filename::String,decoding::Vector{Int64})

    bigA=load(filename)
    condition(bigA[2],decoding, getStimuliP1to4(),90)

end


function conditionP5to20(filename::String,decoding::Vector{Int64})

    bigA=load(filename)
    condition(bigA[2],decoding, getStimuli(),0)

end


