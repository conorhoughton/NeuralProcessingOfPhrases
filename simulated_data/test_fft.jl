
function fourierMode(i)
    exp(-2*pi*(i-1)*im/48)
end


f=Float64[]

open("electrode_example.txt") do file
    for line in eachline(file)
        if strip(line)!=""
            push!(f,parse(Float64,strip(line)))
        end
    end
end

coeff=0.0+0.0*im

for (i,fi) in enumerate(f)
    global coeff
    coeff+=fourierMode(i)*fi
end


println(coeff)
