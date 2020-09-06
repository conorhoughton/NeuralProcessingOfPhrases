using Random
using Statistics

allNumbers=zeros(Float64,1152,300)

open("all_vectors.txt") do file

    for (rC,line) in enumerate(eachline(file))
        if strip(line)!=""
            thisRow=[parse(Float64,x) for x in split(strip(line)," ")]
            allNumbers[rC,:]=thisRow
        end
    end
end

println(std(allNumbers))

sigma=std(allNumbers)

println(sigma*sqrt(3))

println(maximum(allNumbers))
println(minimum(allNumbers))

a=0.34

#allNumbers=2*a*rand(Float64,1152,300)-a*ones(Float64,1152,300)

allNumbers = allNumbers[shuffle(1:end), :]

mask=zeros(Float64,1152,300)

for i in 1:1152
    for j in 1:300
        mask[i,j]=(-1)^i
    end
end

allNumbers=allNumbers.*mask

coeffs=sum(allNumbers,dims=1)

println(maximum(coeffs)," ",minimum(coeffs))

println(mean(coeffs)," ",std(coeffs))

