
using Serialization
using MCMCChains
using DataFrames
using StatisticalRethinking
using Gadfly,Cairo,Fontconfig


bigFrame=DataFrame(deserialize("example_chain.jls"))

bigFrame=bigFrame[!,r"itpcC"]

rename!(bigFrame,[:advp,:rrrr,:rrrv,:avav,:anan,:phmi])

println(hpdi((bigFrame[!,:anan]-bigFrame[!,:rrrr])))

println(hpdi((bigFrame[!,:anan]-bigFrame[!,:advp])))

println(hpdi((bigFrame[!,:advp]-bigFrame[!,:rrrr])))
