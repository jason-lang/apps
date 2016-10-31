#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "requested opinions"
#set xrange [0:19]
set yrange [-1:25]
set key top left
set terminal postscript eps enhanced color 18
set output "experiments/experiment17/partners.eps"
plot "experiments/experiment17/agents-partners/Cheating" title "Cheating" smooth bezier with linespoints,\
     "experiments/experiment17/agents-partners/Connected" title "Connected" smooth bezier with linespoints,\
     "experiments/experiment17/agents-partners/FordPrefect" title "FordPrefect" smooth bezier with linespoints,\
     "experiments/experiment17/agents-partners/Honest" title "Honest" smooth bezier with linespoints,\
     "experiments/experiment17/agents-partners/Next" title "Next" smooth bezier with linespoints,\
     "experiments/experiment17/agents-partners/Uno" title "Uno" smooth bezier with linespoints
