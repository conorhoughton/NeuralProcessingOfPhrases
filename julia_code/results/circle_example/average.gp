
file="outlier.txt"

set size 0.75,0.75

plot file us 1:3  title "samples"  w lines 
replot file us 1:5  title "bootstrap" w lines



