using DataFrames

function loadLocs()

    electrodeLocs=DataFrame(x=Float64[],y=Float64[],names=String[])

    layoutFile="EEG1005.lay"
    lines=readlines(layoutFile)

    for line in lines
    	entries=split(line)
    	push!(electrodeLocs,[parse(Float64,entries[2]),parse(Float64,entries[3]),lowercase(entries[6])])
    end

    electrodeLocs
end
