using LaTeXStrings
using Serialization
using MCMCChains
using DataFrames
using StatisticalRethinking
using Gadfly,Cairo,Fontconfig


bigFrame=DataFrame(deserialize("model1_chain_new.jls"))

bigFrame=bigFrame[!,r"itpcP"]



partFrame=DataFrame(name=String[],min=Float64[],mean=Float64[],max=Float64[])

for i in 1:16
    
    (thisMin,thisMax)=hpdi(bigFrame[!,i];alpha=0.03)
    thisMean=mean(bigFrame[!,i])
    push!(partFrame,[string(i),thisMin,thisMean,thisMax])
    
end

sort!(partFrame,:mean)

plt=Gadfly.plot(partFrame, y=:name,x=:mean, xmin=:min, xmax=:max,
                Geom.point, Geom.errorbar,Guide.xlabel("α_p"),
                Guide.ylabel("participants"),Guide.yticks(label=false),
                style(major_label_font="CMU Serif",minor_label_font="CMU Serif"),
                Theme(background_color="white",errorbar_cap_length=0mm,line_width=0.25mm,default_color="black")
                );

draw(PDF("participants.pdf", 8cm, 8cm), plt)

