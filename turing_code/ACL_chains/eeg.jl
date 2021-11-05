using MCMCChains
using Serialization
using DataFrames
using CSV
using Gadfly
using Cairo, Fontconfig

include("load_locations.jl")


make=false
printValues=false

function loadDF(chainName)
        
    electrodeValues=DataFrame()
    locationsDF=loadLocs()
    
    chn=deserialize(chainName)
    df=DataFrame(chn)[:,r"itpcE"]
    electrodeValues.keys=names(df)
    electrodeValues.means=mean.(eachcol(df))
    electrodeValues.index=[parse(Int64,match(r"\d+",x).match) for x in names(df)]
    
    locations=DataFrame(CSV.File("channel_list.txt",header=0))

    rename!(locations,[:index,:names])
    
    electrodeValues=innerjoin(electrodeValues,locations,on=:index)

    electrodeValues.names.=lowercase.(electrodeValues.names)
    
    electrodeValues=innerjoin(electrodeValues,locationsDF,on=:names)

    electrodeValues

end

if make==true
    electrodeValues=loadDF("model1_chain.jls")
    serialize("model1_electrodes.df",electrodeValues)
elseif printValues==true
    electrodeValues=deserialize("model1_electrodes.df")
    println(electrodeValues)
else
    electrodeValues=deserialize("model1_electrodes.df")
    locationsDF=loadLocs()
    
    draw_size=8
    lambda=1.0 #needs to be adjusted to get the circle circular
    dot_size=draw_size/3 #also divided by 10
    
    thisPlot=plot(layer(electrodeValues,x=:x,y=:y,color=:means,size=[dot_size*mm]),layer(x=[0.0],y=[0.0],size=[(draw_size*0.35)*cm],color=[colorant"grey"]),layer(x=[0.0],y=[1.35],shape=[Shape.utriangle],size=[(draw_size*0.065)*cm],color=[colorant"grey"]),Theme(background_color="white",key_position = :none,grid_color = nothing),Guide.xticks(ticks=nothing),Guide.yticks(ticks=nothing),Guide.xlabel(nothing),Guide.ylabel(nothing))
    
    draw(PNG("eeg.png", lambda*draw_size*cm, draw_size*cm), thisPlot)
end
