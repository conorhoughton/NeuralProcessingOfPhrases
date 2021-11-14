
using Gadfly,Cairo,Fontconfig
using CSV
using DataFrames
using Statistics
using HypothesisTests

printSig=false

conditions = ["anan","advp","rrrv","phmi","avav","rrrr"]

newConditions = ["AN","ML","RV","MP","AV","RR"]

dfList=[]

participants=[string(i) for i in 1:16]

for (i,condition) in enumerate(conditions)
    global participants
    filename = "itpc_"*condition*"_all.txt"
    df = DataFrame(CSV.File(filename,delim=" ",header=false))
    filter!(row -> row.Column1 ==1.5625, df)
    if condition ∉ ["rrrr","rrrv","advp"]
        df=df[:,Not(Between(:Column2,:Column5))]
        df=df[:,Not(:Column22)]
        df=df[:,Not(:Column1)]
        oldNames=["Column"*string(i) for i in 6:21]
        rename!(df,oldNames.=>participants)
    else
        df=df[:,Not(:Column18)]
        oldNames=["Column"*string(i) for i in 2:17]
        df=df[:,Not(:Column1)]
        rename!(df,oldNames.=>participants)        
    end
    df=hcat(df,DataFrame(name=[newConditions[i]]))
    push!(dfList,df)
end

data=stack(reduce(vcat,dfList))

layer1=layer(data,x=:name, y=:value, Stat.x_jitter(range=0.5), Geom.point);

means = groupby(data, :name)
means = combine(means, nrow, :value => mean => :mean)

layer2=layer(means,x=:name, y=:mean, shape=[Shape.hline],Geom.point,Theme(default_color="black",point_size=2.5mm));

siga=["AN","AN","AN","AN"]
sigb=reverse(["RV","MP","AV","RR"])
sigy=[0.5,0.475,0.45,0.425]

layer3=layer(x=siga,xend=sigb,y=sigy,yend=sigy,Geom.segment,Theme(default_color="black"));

sigy1=[0.5,0.475,0.45,0.425]
sigy2=[0.49,0.465,0.44,0.415]

layer4=layer(x=siga,xend=siga,y=sigy1,yend=sigy2,Geom.segment,Theme(default_color="black"));

layer5=layer(x=sigb,xend=sigb,y=sigy1,yend=sigy2,Geom.segment,Theme(default_color="black"));

plt=plot(layer2,layer5,layer4,layer3,layer1,style(major_label_font="CMU Serif",minor_label_font="CMU Serif",
                                      major_label_font_size=16pt,minor_label_font_size=14pt),Theme(background_color="white"),Guide.xlabel(nothing),Guide.ylabel("ITPC"));

#draw(PNG("itpc.png",8cm,8cm),plt)
draw(PDF("itpc.pdf",8cm,8cm),plt)

if printSig

    for i in 1:6
        for j in i+1:6
            
            x=filter(row -> row.name == newConditions[i], data).value
            y=filter(row -> row.name == newConditions[j], data).value
            
            println(newConditions[i],"-",newConditions[j]," ",pvalue(SignedRankTest(x,y),tail=:both))
        end
    end
end
