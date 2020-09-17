unset key

plot for [i=2:17	] "all.txt" us 1:i w lines  lt -1 lc rgb "#87CEFA"

replot "av.txt" us 1:2 w lines lw 3 lt -1 lc rgb 'black'

set arrow from 3.125, graph 0 to 3.125, graph 1 nohead front lw 1 lc rgb 'red'
set arrow from 1.5625, graph 0 to 1.5625, graph 1 nohead front lw 1  lc rgb 'red'



set xlabel "frequency, Hz"

set ylabel "power"

set size 0.75,0.75	

replot