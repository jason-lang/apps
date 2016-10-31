#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "requested opinions"
set key top left
set terminal postscript eps color enhanced
set output "experiment7/partners.eps"
plot "experiment7/agents-partners/Cheating_1" title "Cheating_1" smooth csplines,\
     "experiment7/agents-partners/Cheating_2" title "Cheating_2" smooth csplines,\
     "experiment7/agents-partners/Lazy_1" title "Lazy_1" smooth csplines,\
     "experiment7/agents-partners/Lazy_2" title "Lazy_2" smooth csplines,\
     "experiment7/agents-partners/Simple_1" title "Simple_1" smooth csplines,\
     "experiment7/agents-partners/Simple_2" title "Simple_2" smooth csplines,\
     "experiment7/agents-partners/Simple_3" title "Simple_3" smooth csplines
