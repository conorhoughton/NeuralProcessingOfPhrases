
using Serialization
using MCMCChains
using DataFrames
using StatisticalRethinking
using Gadfly,Cairo,Fontconfig


bigFrame=DataFrame(deserialize("example_chain.jls"))

bigFrame=bigFrame[!,r"itpcC"]

conditions=["advp","rrrr","rrrv","avav","anan","phmi"]

rename!(bigFrame,conditions)

compareConds=["anan","advp","avav","phmi","rrrv","rrrr"]

compareFrame=DataFrame(name=String[],min=Float64[],mean=Float64[],max=Float64[])

for i in 1:6
    for j in i+1:6
        a=compareConds[i]
        b=compareConds[j]
        thisName=a*"-"*b
        (thisMin,thisMax)=hpdi((bigFrame[!,a]-bigFrame[!,b]);alpha=0.05)
        thisMean=mean(bigFrame[!,a]-bigFrame[!,b])
        push!(compareFrame,[thisName,thisMin,thisMean,thisMax])
    end
end
        
plt=Gadfly.plot(compareFrame, x=:name, y=:mean, ymin=:min, ymax=:max, Geom.point, Geom.errorbar,Theme(background_color="white"));

draw(PNG("test.png", 20cm, 20cm), plt)
