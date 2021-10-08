using MCMCChains
using Serialization
using DataFrames
using CSV


using Gadfly
using Cairo, Fontconfig

include("load_locations.jl")

electrodeValues=DataFrame()

locationsDF=loadLocs()

let
    global electrodeValues
    global locationsDF
    
    chn=deserialize("example_chain.jls")
    df=DataFrame(chn)[:,r"itpcE"]
    electrodeValues.keys=names(df)
    electrodeValues.means=mean.(eachcol(df))
    electrodeValues.index=[parse(Int64,match(r"\d+",x).match) for x in names(df)]
    
    locations=DataFrame(CSV.File("channel_list.txt",header=0))

    rename!(locations,[:index,:names])
    
    electrodeValues=innerjoin(electrodeValues,locations,on=:index)

    electrodeValues.names.=lowercase.(electrodeValues.names)
    
    electrodeValues=innerjoin(electrodeValues,locationsDF,on=:names)

    println(electrodeValues)

    
end



thisPlot=plot(layer(electrodeValues,x=:x,y=:y,color=:means,size=[5mm]),layer(locationsDF,x=:x,y=:y,size=[1mm]),Theme(background_color="white"))

draw(PNG("test.png", 8inch, 8inch), thisPlot)
