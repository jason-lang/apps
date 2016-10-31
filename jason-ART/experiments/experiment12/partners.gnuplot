#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "requested opinions"
set xrange [0:19]
set yrange [-1:25]
set key top left
set terminal postscript eps enhanced color 18
set output "experiments/experiment12/partners.eps"
plot "experiments/experiment12/agents-partners/Cheating_1" title "Cheating_1" lc "black" smooth bezier with linespoints,\
     "experiments/experiment12/agents-partners/Lazy_1" title "Lazy_1" lc "black" smooth bezier with linespoints,\
     "experiments/experiment12/agents-partners/Lazy_2" title "Lazy_2" lc "black" smooth bezier with linespoints,\
     "experiments/experiment12/agents-partners/Simple_1" title "Honest_1" lc "black" smooth bezier with linespoints,\
     "experiments/experiment12/agents-partners/Simple_2" title "Honest_2" lc "black" smooth bezier with linespoints,\
     "experiments/experiment12/agents-partners/Simple_3" title "Honest_3" lc "black" smooth bezier with linespoints,\
     "experiments/experiment12/agents-partners/Simple_4" title "Honest_4" lc "black" smooth bezier with linespoints
