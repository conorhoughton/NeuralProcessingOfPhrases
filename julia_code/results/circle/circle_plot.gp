
#set palette model RGB defined (1 'red', 2 'blue', 3 'red', 4 'red', 5 'green', 6 'blue', 7 'blue', 8 'red', 9 'red', 10 'blue', 11 'blue', 12 'red', 13 'red', 14 'green', 15 'red', 16 'red', 17 'blue', 18 'blue', 19 'red', 20 'blue', 21 'blue', 22 'blue', 23 'red', 24 'red', 25 'green', 26 'blue', 27 'blue', 28 'red', 29 'red', 30 'green', 31'blue', 32 'blue')

set palette model RGB defined  (1 'red', 2 'red', 3 'orange', 4 'orange', 5 'orange', 6 'orange', 7 'orange', 8'yellow', 9 'yellow', 10 'yellow', 11 'yellow', 12 'blue', 13 'green', 14 'green', 15 'green', 16 'blue', 17 'blue', 18 'purple', 19 'purple', 20 'purple', 21 'purple', 22 'purple', 23 'black', 24 'black', 25 'black', 26 'black', 27 'black', 28 'brown', 29 'brown', 30 'brown', 31 'brown', 32 'brown')

plot "circular_values.txt" us (($1)+($4)):3:(int($2)) with points palette
