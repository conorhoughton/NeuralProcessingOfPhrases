
unset key
unset tics


set xrange [-1.2:1.2]
set yrange [-1.2:1.2]
set size square
set size 0.75,0.75


plot "<echo '0.038329902350731186 -0.18557929522603037'" ps 3 pt 7 lc rgb "red"


replot "p_p15e10.txt" us 1:2 ps 3 pt 6 lc rgb "black"

#(0.18152466937107592, 0.35269888938085936, 0.047520118990717765)

r1=0.047520118990717765
r2=0.35269888938085936
r=0.18152466937107592
set style fill solid noborder
set object circle at first 0,0 back size r2 fillcolor rgb 'gray'
set object circle at first 0,0 back size r1 fillcolor rgb 'white'
set style fill empty border lt -1
set object circle at first 0,0 front size r fillcolor rgb 'black'
replot