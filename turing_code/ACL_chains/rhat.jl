using LaTeXStrings
using Serialization
using MCMCChains
using DataFrames
using StatisticalRethinking
using Gadfly,Cairo,Fontconfig


chn=deserialize("model1_chain.jls")
df=DataFrame(summarize(chn))

lyr1=Gadfly.layer(df, y=:ess, x=:rhat, Geom.point,Theme(point_size=1pt,default_color="black"),yintercept=[100],xintercept=[1.06], Geom.vline, Geom.hline);

df=filter(:parameters => x -> occursin(r"itpcC",string(x)), df)

lyr2=Gadfly.layer(df, y=:ess, x=:rhat, Geom.point,Theme(point_size=2.5pt,default_color="red"));

plt=Gadfly.plot(lyr2,lyr1,Guide.xlabel("rhat"),Guide.ylabel("ess"),Theme(background_color="white"))

draw(PNG("rhat_ess.png", 16cm, 6cm), plt)

