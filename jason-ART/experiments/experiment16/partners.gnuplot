#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "requested opinions"
#set xrange [0:20]
set yrange [-1:25]
set key top left
set terminal postscript eps color enhanced
set output "experiment16/partners.eps"
plot "experiment16/agents-partners/Cheating_1" title "Cheating_1" smooth bezier,\
     "experiment16/agents-partners/Connected" title "Connected" smooth bezier,\
     "experiment16/agents-partners/FordPrefect" title "FordPrefect" smooth bezier,\
     "experiment16/agents-partners/Honest_1" title "Honest_1" smooth bezier,\
     "experiment16/agents-partners/Honest_2" title "Honest_2" smooth bezier,\
     "experiment16/agents-partners/Honest_3" title "Honest_3" smooth bezier,\
     "experiment16/agents-partners/Honest_4" title "Honest_4" smooth bezier,\
     "experiment16/agents-partners/Next" title "Next" smooth bezier,\
     "experiment16/agents-partners/Uno" title "Uno" smooth bezier
