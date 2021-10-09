using Serialization
using MCMCChains
using DataFrames
using Gadfly,Cairo,Fontconfig

bigFrame=DataFrame(deserialize("example_chain.jls"))

bigFrame=bigFrame[!,r"itpcC"]

rename!(bigFrame,[:advp,:rrrr,:rrrv,:avav,:anan,:phmi])

longFrame=stack(bigFrame,1:6)

plt=plot(longFrame,x=:variable,y=:value,Geom.violin,Theme(background_color="white"));

draw(PNG("test.png"),plt)

