
unset key
unset tics


set xrange [-1.2:1.2]
set yrange [-1.2:1.2]
set size square
set size 0.5,0.5


plot "r_e17_phrases.txt" us 1:2 ps 3 pt 6 lc rgb "red"

set style fill solid noborder

set object circle at first 0,0 back size 1.05 fillcolor rgb 'gray'
set object circle at first 0,0 back size 1.0 fillcolor rgb 'white'
set object circle at first 0,0 back size 0.05 fillcolor rgb 'gray'



replot