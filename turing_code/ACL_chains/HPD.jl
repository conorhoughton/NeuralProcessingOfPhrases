using Serialization
using MCMCChains
using DataFrames
using StatisticalRethinking
using Gadfly,Cairo,Fontconfig

 
bigFrame=DataFrame(deserialize("model1_chain_new.jls"))

bigFrame=bigFrame[!,r"itpcC"]

conditions=["ML","RR","RV","AV","AN","MP"]

rename!(bigFrame,conditions)

compareConds=["AN","ML","RV","MP","AV","RR"]

compareFrame=DataFrame(name=String[],min=Float64[],mean=Float64[],max=Float64[])

for i in 1:6
    for j in i+1:6
        a=compareConds[i]
        b=compareConds[j]
        thisName=a*"-"*b
        (thisMin,thisMax)=hpdi((bigFrame[!,a]-bigFrame[!,b]);alpha=0.03)
        thisMean=mean(bigFrame[!,a]-bigFrame[!,b])
        push!(compareFrame,[thisName,thisMin,thisMean,thisMax])
    end
end

sort!(compareFrame,:mean)

plt=Gadfly.plot(compareFrame, y=:name, x=:mean, xmin=:min, xmax=:max, Geom.point, Geom.errorbar,style(major_label_font="CMU Serif",minor_label_font="CMU Serif"),Theme(background_color="white",errorbar_cap_length=0mm,line_width=0.25mm,default_color="black"),Guide.xlabel("α_c₁-α_c₂"),Guide.ylabel(nothing),Coord.Cartesian(xmin=-1,xmax=8));

#draw(PNG("HPD.png", 16cm, 8cm), plt)
draw(PDF("HPD.pdf", 16cm, 8cm), plt)

