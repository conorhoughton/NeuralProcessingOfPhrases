using MCMCChains
using Serialization
using DataFrames
using CSV
using Gadfly
using Cairo, Fontconfig

include("load_locations.jl")


make=false


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
    electrodeValues=loadDF("example_chain.jls")
    serialize("example_electrodes.df",electrodeValues)
else
    electrodeValues=deserialize("example_electrodes.df")
    locationsDF=loadLocs()
    
    draw_size=20
    dot_size=draw_size/3 #also divided by 10
    
    thisPlot=plot(layer(electrodeValues,x=:x,y=:y,color=:means,size=[dot_size*mm]),layer(locationsDF,x=:x,y=:y,size=[1mm],color=[colorant"black"]),layer(x=[0.0],y=[0.0],size=[(draw_size*0.35)*cm]),layer(x=[0.0],y=[1.7],shape=[Shape.utriangle],size=[(draw_size*0.075)*cm]),Theme(background_color="white"))

    draw(PNG("test.png", draw_size*cm, draw_size*cm), thisPlot)
end
