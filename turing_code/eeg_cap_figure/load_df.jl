using MCMCChains
using Serialization
using DataFrames
using CSV

electrodeValues=DataFrame()

let
    chn=deserialize("fit_all_3_p16.jls")
    df=DataFrame(chn)[:,r"itpcC"]
    electrodeValues.keys=names(df)
    electrodeValues.means=mean.(eachcol(df))
    electrodeValues.index=[parse(Int64,match(r"\d+",x).match) for x in names(df)]
    
    locations=DataFrame(CSV.File("channel_list.txt",header=0))
    rename!(locations,[:index,:location])
    
    electrodeValue=innerjoin(electrodeValues,locations,on=:index)
    
end
