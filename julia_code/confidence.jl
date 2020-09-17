
# the null hypothesis

using Statistics
using Random
include("mean_res.jl")


function randomPhase()
    angle=2*pi*rand()
    exp(angle*im)
end


function confidenceInterval(pointsN::Int64,trialN::Int64,participantN::Int64,confidence::Float64)

    itpcGrandAv=randomITPC(pointsN,trialN,participantN)
    
    sort!(itpcGrandAv)

    index=convert(Int64,0.95*pointsN)
    
    (mean(itpcGrandAv),itpcGrandAv[index],itpcGrandAv[pointsN-index])

end

function randomITPC(pointsN::Int64,trialN::Int64,participantN::Int64)
    
    itpcGrandAv=Float64[]

    for pointsI in 1:pointsN
        itpc=Float64[]
        for participantI in 1:participantN
            phases=Complex[]
            for trialI in 1:trialN
                push!(phases,randomPhase())
            end
            push!(itpc,meanResultant(phases)[1])
        end
        push!(itpcGrandAv,mean(itpc))
    end

    itpcGrandAv

end
