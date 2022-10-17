
using Serialization
using MCMCChains
using DataFrames
using StatisticalRethinking
using Gadfly,Cairo,Fontconfig


chn=deserialize("model1_chain_new.jls")
df=DataFrame(summarize(chn))

#lyr1=Gadfly.layer(df, y=:ess, x=:rhat, Geom.point,Theme(point_size=1pt,default_color="black"),yintercept=[100],xintercept=[1.06], Geom.vline, Geom.hline);
lyr1=Gadfly.layer(df, y=:ess, x=:rhat, Geom.point,Theme(point_size=1pt,default_color="black"));

df=filter(:parameters => x -> occursin(r"itpcC",string(x)), df)

lyr2=Gadfly.layer(df, y=:ess, x=:rhat, Geom.point,Theme(point_size=2.5pt,default_color="red"));

plt=Gadfly.plot(lyr2,lyr1,Guide.xlabel("rhat"),Guide.ylabel("ess"),style(major_label_font="CMU Serif",minor_label_font="CMU Serif"),Theme(background_color="white"))

draw(PDF("rhat_ess.pdf", 8cm, 8cm), plt)

