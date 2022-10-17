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
    electrodeValues=loadDF("model1_chainₙew.jls")
    serialize("model1_electrodes.df",electrodeValues)
elseif printValues==true
    electrodeValues=deserialize("model1_electrodes.df")
    println(electrodeValues)
else
    electrodeValues=deserialize("model1_electrodes.df")
    locationsDF=loadLocs()
    
    draw_size=8
    lambda=1.1 #needs to be adjusted to get the circle circular
    dot_size=draw_size/3 #also divided by 10

    outside=2
    
    thisPlot=plot(
        layer(electrodeValues,x=:x,y=:y,color=:means,size=[dot_size*mm]),
        layer(x=[0.0],y=[0.0],size=[(draw_size*0.375)*cm],color=[colorant"grey"]),
        layer(x=[0.0],y=[1.8],shape=[Shape.utriangle],size=[(draw_size*0.065)*cm],color=[colorant"grey"]),
        Guide.xticks(ticks=nothing),Guide.yticks(ticks=nothing),
        Guide.xlabel(nothing),Guide.ylabel(nothing),Guide.colorkey(title="α_e"),
        Coord.Cartesian(xmin=-outside,xmax=outside,ymin=-outside,ymax=outside),
        style(major_label_font="CMU Serif",minor_label_font="CMU Serif"),
        Theme(background_color="white",key_position = :below,grid_color = nothing),
    )
    
    draw(PDF("eeg.pdf", lambda*draw_size*cm, draw_size*cm), thisPlot)
end
