#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "money"
set key top left
set terminal postscript eps color enhanced
set output "experiment14/bank-a.eps"
plot "experiment14/agents-bank/Cheating_1" title "Cheating_1" with linespoints,\
     "experiment14/agents-bank/ForTrust" title "ForTrust" with linespoints,\
     "experiment14/agents-bank/Honest_1" title "Honest_1" with linespoints,\
     "experiment14/agents-bank/Honest_2" title "Honest_2" with linespoints,\
     "experiment14/agents-bank/Honest_3" title "Honest_3" with linespoints,\
     "experiment14/agents-bank/Honest_4" title "Honest_4" with linespoints,\
     "experiment14/agents-bank/Lazy_1" title "Lazy_1" with linespoints,\
     "experiment14/agents-bank/Lazy_2" title "Lazy_2" with linespoints

set output "experiment14/bank-b.eps"
plot "experiment14/agents-bank/Cheating_1" title "Cheating_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment14/agents-bank/ForTrust" title "ForTrust" with yerrorbars, "" smooth csplines notitle,\
     "experiment14/agents-bank/Honest_1" title "Honest_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment14/agents-bank/Honest_2" title "Honest_2" with yerrorbars, "" smooth csplines notitle,\
     "experiment14/agents-bank/Honest_3" title "Honest_3" with yerrorbars, "" smooth csplines notitle,\
     "experiment14/agents-bank/Honest_4" title "Honest_4" with yerrorbars, "" smooth csplines notitle,\
     "experiment14/agents-bank/Lazy_1" title "Lazy_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment14/agents-bank/Lazy_2" title "Lazy_2" with yerrorbars, "" smooth csplines notitle
