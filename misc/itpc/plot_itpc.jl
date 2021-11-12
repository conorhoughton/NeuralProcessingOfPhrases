
using Gadfly,Cairo,Fontconfig
using CSV
using DataFrames
using Statistics

condition = "anan"

filename = "itpc_"*condition*"_all.txt"

df = DataFrame(CSV.File(filename,delim=" ",header=false))

df=df[:,Not(Between(:Column2,:Column5))]
df=df[:,Not(:Column22)]

oldNames=["Column"*string(i) for i in 6:21]
participants=[string(i) for i in 1:16]

rename!(df,[:Column1].=>[:frequency])
rename!(df,oldNames.=>participants)

df=stack(df,2:17)

#layer1=layer(df,x=:frequency,y=:value,group=:variable,Geom.line)
layer1=layer(df,x=:frequency,y=:value,group=:variable,Geom.boxplot[(; method=:tukey, suppress_outliers=false)]);

gdf = groupby(df, :frequency)
gdf=combine(gdf, nrow, :value => mean => :mean)

layer2=layer(gdf,x=:frequency,y=:mean,Geom.line,Theme(default_color="black",line_width=1mm))

plt=plot(layer2,layer1,Theme(background_color="white"))

draw(PNG("test.png",6cm,6cm),plt)
