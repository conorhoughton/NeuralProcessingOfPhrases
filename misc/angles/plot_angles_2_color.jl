
using Gadfly,Cairo,Fontconfig
using CSV
using DataFrames
using Statistics
using HypothesisTests

df = DataFrame(CSV.File("all_itpc.txt",delim=" ",header=false))

df=rename(df,["participant","electrode","angle","length"])


#12 -> T7
#16 -> T8
#25 -> Pz

yticks=[-π,-π/2,0,π/2,π]
labels=Dict(zip(yticks,["-π","-π/2","0","π/2","π"]))

layer1=layer(df,x=:participant,y=:angle,color=[colorant"black"],Stat.x_jitter(range=0.5),
             Geom.point
             );

layer2=layer(filter(row -> row.electrode==12,df),x=:participant,y=:angle,color=[colorant"red"],
             Geom.point,
             );


layer3=layer(filter(row -> row.electrode==16,df),x=:participant,y=:angle,color=[colorant"#ADFF2F"],
             Geom.point,
             );


layer4=layer(filter(row -> row.electrode==25,df),x=:participant,y=:angle,color=[colorant"blue"],
             Geom.point,
             );



plt=plot(layer4,layer3,layer2,layer1,
         style(major_label_font="CMU Serif",minor_label_font="CMU Serif"),
         Theme(background_color="white",
               key_position = :none,highlight_width = 0.0mm,point_size=0.5mm),
         Guide.xlabel("participants"),Guide.xticks(label=false),
         Guide.ylabel("θ"),Guide.yticks(ticks=yticks),
         Scale.y_continuous(labels = y -> labels[y]),
         Coord.Cartesian(ymin=-π,ymax=π),
         Scale.color_discrete,
         Scale.x_discrete
         );
   

draw(PNG("angles.png",8cm,4cm),plt)
draw(PDF("angles.pdf",8cm,4cm),plt)
