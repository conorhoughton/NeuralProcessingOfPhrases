unset key

set yrange [0.0:0.7]

plot for [i=2:21] "itpc_anan_all.txt" us 1:i w lines  lt -1 lc rgb "#87CEFA"
#plot for [i=2:17] "itpc_rrrr_all.txt" us 1:i w lines  lt -1 lc rgb "#87CEFA"

replot "itpc_anan_grand_av.txt" us 1:2 w lines lw 3 lt -1 lc rgb 'black'

set arrow from 3.125, graph 0 to 3.125, graph 1 nohead front lw 1 lc rgb 'red'
set arrow from 1.5625, graph 0 to 1.5625, graph 1 nohead front lw 1  lc rgb 'red'

replot "< echo '3.025 0.075'" w p ls 3 ps 1 lw 1 lc rgb 'red'
replot "< echo '3.125 0.075'" w p ls 3 ps 1 lw 1 lc rgb 'red'
replot "< echo '3.225 0.075'" w p ls 3 ps 1 lw 1 lc rgb 'red'


replot "< echo '1.4625 0.075'" w p ls 3 ps 1 lw 1 lc rgb 'red'
replot "< echo '1.5625 0.075'" w p ls 3 ps 1 lw 1 lc rgb 'red'
replot "< echo '1.6625 0.075'" w p ls 3 ps 1 lw 1 lc rgb 'red'



set xlabel "frequency, Hz"

set ylabel "ITPC"

set size 0.5,0.5	

replot