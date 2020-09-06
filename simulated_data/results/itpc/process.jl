
using Statistics

freq=Float64[]

open("freq.txt") do file
    for line in eachline(file)
        if strip(line)!=""
            push!(freq,parse(Float64,line))
        end
    end
end

open("rrrr_all.dat") do file

    for (f,line) in enumerate(eachline(file))
        if line!=""
            thisLine=[parse(Float64,strip(x)) for x in split(strip(line),",")]
            grandAverage=mean(thisLine)
            print(freq[f]," ",grandAverage)
            for itpc in thisLine
                print(" ",itpc)
            end
            println()
        end
    end

end
