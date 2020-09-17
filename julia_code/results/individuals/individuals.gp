
set style data histogram
set style histogram cluster gap 1

set size 0.5,0.5

set xlabel "participant number"
set ylabel "ITPC"

set boxwidth 0.9
set style fill solid border rgb "black" 
set auto x
set yrange [0:0.75]
set xtics nomirror
set ytics nomirror
set xtics out

set ytics out

unset key

plot 'rrrr_test.txt' using 2:xtic(1) title col ls -1 fs pattern 3, \
        '' using 4:xtic(1) title col ls -1 fs pattern 0


replot 0.15459077243018546 ls 2 lc rgb "red" lw 1 title ""
replot 0.21009005603679848 ls 2 lc rgb "red" lw 1 title ""
replot 0.18178793944888116 ls -1 lc rgb "red" lw 1 title ""
