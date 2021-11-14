
using Gadfly,Cairo,Fontconfig
using CSV
using DataFrames
using Statistics
using HypothesisTests

df = DataFrame(CSV.File("all_itpc.txt",delim=" ",header=false))

df=rename(df,["participant","electrode","angle","length"])

colors=["black" for i in 1:32]
colors[12]="red"
colors[16]="blue"


yticks=[-π,-π/2,0,π/2,π]
labels=Dict(zip(yticks,["-π","-π/2","0","π/2","π"]))

plt=plot(df,x=:participant,y=:angle,color=:electrode,
         Geom.point,
         style(major_label_font="CMU Serif",minor_label_font="CMU Serif"),
         Theme(background_color="white",key_position = :none),
         Guide.xlabel("participants"),Guide.xticks(label=false),
         Guide.ylabel("θ"),Guide.yticks(ticks=yticks),
         Scale.y_continuous(labels = y -> labels[y]),
         Coord.Cartesian(ymin=-π,ymax=π),
         Scale.color_discrete,
         Scale.x_discrete
         );

draw(PNG("angles.png",8cm,8cm),plt)
