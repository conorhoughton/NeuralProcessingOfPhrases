
using StatsBase

println(sample(collect(1:300),32;replace=false, ordered=true))
