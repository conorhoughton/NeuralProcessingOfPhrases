using Serialization
using Distributions
using MCMCChains
using DataFrames
using Gadfly,Cairo,Fontconfig
using StatsFuns

bigFrame=DataFrame(deserialize("model1_chain.jls"))

bigFrame=bigFrame[!,r"itpcC"]

rename!(bigFrame,[:advp,:rrrr,:rrrv,:avav,:anan,:phmi])

bigFrame=select!(bigFrame,[:anan,:advp,:rrrv,:phmi,:avav,:rrrr])

priorV=rand(Normal(-1.0,1.0),length(bigFrame.advp))

bigFrame[!,:prior]=priorV

longFrame=stack(bigFrame,1:7)

longFrame[!,:isData].=(longFrame.variable.!="prior")

plt=plot(longFrame,x=:variable,y=:value,color=:isData,Geom.violin,Theme(background_color="white", key_position = :none),Guide.xlabel(nothing),Guide.ylabel(nothing),Coord.Cartesian(ymin=-5,ymax=2));

draw(PNG("violin.png",8cm,8cm),plt)
