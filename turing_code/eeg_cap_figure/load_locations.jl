using DataFrames

function loadLocs()

    electrodeLocs=DataFrame(x=Float64[],y=Float64[],name=String[])

    layoutFile="EEG1005.lay"
    lines=readlines(layoutFile)

    for line in lines
    	entries=split(line)
        println(entries)
    	push!(electrodeLocs,[parse(Float64,entries[2]),parse(Float64,entries[3]),entries[6]])
    end

    electrodeLocs
end
