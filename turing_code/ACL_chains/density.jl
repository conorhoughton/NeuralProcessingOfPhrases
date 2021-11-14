using DataFrames
using CategoricalArrays
using Gadfly
using MCMCChains
using Serialization
using Cairo, Fontconfig

# Define the experiment.
n_iter = 100
n_name = 3
n_chain = 2

# Experiment results.

chn=deserialize("model1_chain_new.jls")

df = DataFrame(chn)
df[!, :chain] = categorical(df.chain)

lyrChains1=layer(df, x="itpcC[1]", color=:chain, Geom.density)
lyrAverage1=layer(df, x="itpcC[1]", Geom.density,Theme(default_color="black",line_width=2pt))
#plt1=plot(lyrAverage1,lyrChains1,Guide.xlabel("ML"),Theme(background_color="white",key_position = :none),Coord.Cartesian(xmin=-8,xmax=3))


lyrChains2=layer(df, x="itpcC[2]", color=:chain, Geom.density)
lyrAverage2=layer(df, x="itpcC[2]", Geom.density,Theme(default_color="black",line_width=2pt))
#plt2=plot(lyrAverage2,lyrChains2,Guide.xlabel("RR"),Theme(background_color="white",key_position = :none),Coord.Cartesian(xmin=-8,xmax=3))


lyrChains3=layer(df, x="itpcC[3]", color=:chain, Geom.density)
lyrAverage3=layer(df, x="itpcC[3]", Geom.density,Theme(default_color="black",line_width=2pt))
#plt3=plot(lyrAverage3,lyrChains3,Guide.xlabel("RV"),Theme(background_color="white",key_position = :none),Coord.Cartesian(xmin=-8,xmax=3))


lyrChains4=layer(df, x="itpcC[4]", color=:chain, Geom.density)
lyrAverage4=layer(df, x="itpcC[4]", Geom.density,Theme(default_color="black",line_width=2pt))
#plt4=plot(lyrAverage4,lyrChains4,Guide.xlabel("AV"),Theme(background_color="white",key_position = :none),Coord.Cartesian(xmin=-8,xmax=3))

lyrChains5=layer(df, x="itpcC[5]", color=:chain, Geom.density)
lyrAverage5=layer(df, x="itpcC[5]", Geom.density,Theme(default_color="black",line_width=2pt))
#plt5=plot(lyrAverage5,lyrChains5,Guide.xlabel("AN"),Theme(background_color="white",key_position = :none),Coord.Cartesian(xmin=-8,xmax=3))

lyrChains6=layer(df, x="itpcC[6]", color=:chain, Geom.density)
lyrAverage6=layer(df, x="itpcC[6]", Geom.density,Theme(default_color="black",line_width=2pt))
#plt6=plot(lyrAverage6,lyrChains6, Guide.xlabel("MP"),Theme(background_color="white",key_position = :none),Coord.Cartesian(xmin=-8,xmax=3))

# plt123=hstack(plt1,plt2,plt3);
# plt456=hstack(plt4,plt5,plt6);
# plt=vstack(plt123,plt456);

plt=plot(lyrAverage1,lyrAverage2,lyrAverage3,lyrAverage4,lyrAverage5,lyrAverage6, lyrChains1,lyrChains2,lyrChains3,lyrChains4,lyrChains5,lyrChains6,Coord.Cartesian(xmin=-6,xmax=6),yintercept=[0],Geom.hline(size=[2pt],color=["black"]),Guide.xlabel("α_c"),Guide.ylabel("density"),style(major_label_font="CMU Serif",minor_label_font="CMU Serif"),Theme(background_color="white",key_position = :none))

#draw(PNG("density.png", 8cm, 8cm), plt)
draw(PDF("density.pdf", 8cm, 8cm), plt)
