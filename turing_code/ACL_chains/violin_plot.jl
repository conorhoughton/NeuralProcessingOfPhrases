using Serialization
using Distributions
using MCMCChains
using DataFrames
using Gadfly,Cairo,Fontconfig
using StatsFuns

bigFrame=DataFrame(deserialize("model1_chain_new.jls"))

bigFrame=bigFrame[!,r"itpcC"]

rename!(bigFrame,[:ML,:RR,:RV,:AV,:AN,:MP])

bigFrame=select!(bigFrame,[:AN,:ML,:RV,:MP,:AV,:RR])

priorV=rand(Normal(0.0,1.0),length(bigFrame.ML))

bigFrame[!,:prior]=priorV

longFrame=stack(bigFrame,1:7)

longFrame[!,:isData].=(longFrame.variable.!="prior")

layer1=layer(longFrame,x=:variable,y=:value,color=:isData,Geom.violin);


means = groupby(longFrame, :variable)
means = combine(means, nrow, :value => mean => :mean)

layer2=layer(means,x=:variable, y=:mean, shape=[Shape.hline],Geom.point,Theme(default_color="black",point_size=2.5mm));

plt=plot(layer2,layer1,Coord.Cartesian(ymin=-5,ymax=5),style(major_label_font="CMU Serif",minor_label_font="CMU Serif"),Theme(background_color="white",key_position = :none), Guide.xlabel(nothing),Guide.ylabel("α_c"))

#draw(PNG("violin.png",8cm,8cm),plt)
draw(PDF("violin.pdf",8cm,8cm),plt)
