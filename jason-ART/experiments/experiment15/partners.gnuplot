#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "requested opinions"
#set xrange [0:20]
set yrange [-1:25]
set key top left
set terminal postscript eps color enhanced
set output "experiment15/partners.eps"
plot "experiment15/agents-partners/Cheating_1" title "Cheating_1" smooth bezier,\
     "experiment15/agents-partners/Connected" title "Connected" smooth bezier,\
     "experiment15/agents-partners/FordPrefect" title "FordPrefect" smooth bezier,\
     "experiment15/agents-partners/Next" title "Next" smooth bezier,\
     "experiment15/agents-partners/Uno" title "Uno" smooth bezier
