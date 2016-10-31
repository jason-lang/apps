#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "requested opinions"
set key top left
set terminal postscript eps color enhanced
set output "experiment10/partners.eps"
plot "experiment10/agents-partners/Cheating_1" title "Cheating_1" smooth csplines,\
     "experiment10/agents-partners/Lazy_1" title "Lazy_1" smooth csplines,\
     "experiment10/agents-partners/Lazy_2" title "Lazy_2" smooth csplines,\
     "experiment10/agents-partners/Simple_1" title "Simple_1" smooth csplines,\
     "experiment10/agents-partners/Simple_2" title "Simple_2" smooth csplines,\
     "experiment10/agents-partners/Simple_3" title "Simple_3" smooth csplines,\
     "experiment10/agents-partners/Simple_4" title "Simple_4" smooth csplines,\
     "experiment10/agents-partners/Simple_5" title "Simple_5" smooth csplines,\
     "experiment10/agents-partners/Simple_6" title "Simple_6" smooth csplines
