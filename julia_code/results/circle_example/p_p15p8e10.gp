
unset key
unset tics


set xrange [-1.2:1.2]
set yrange [-1.2:1.2]
set size square
set size 0.75,0.75

plot "<echo '0.038329902350731186 -0.18557929522603037'" ps 3 pt 7 lc rgb "red"
replot "<echo '-0.5229281996823959 -0.2286152852429306'" ps 3 pt 7 lc rgb "green"


replot "p_p15e10.txt" us 1:2 ps 3 pt 6 lc rgb "red"
replot "p_p8e10.txt" us 1:2 ps 3 pt 6 lc rgb "green"