#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "money"
set key top left
set terminal postscript eps color enhanced
set output "experiment18/bank-a.eps"
plot "experiment18/agents-bank/Cheating_1" title "Cheating_1" with linespoints,\
     "experiment18/agents-bank/Connected" title "Connected" with linespoints,\
     "experiment18/agents-bank/ForTrust" title "ForTrust" with linespoints,\
     "experiment18/agents-bank/FordPrefect" title "FordPrefect" with linespoints,\
     "experiment18/agents-bank/Honest_1" title "Honest_1" with linespoints,\
     "experiment18/agents-bank/Honest_2" title "Honest_2" with linespoints,\
     "experiment18/agents-bank/Honest_3" title "Honest_3" with linespoints,\
     "experiment18/agents-bank/Honest_4" title "Honest_4" with linespoints,\
     "experiment18/agents-bank/Next" title "Next" with linespoints,\
     "experiment18/agents-bank/Uno" title "Uno" with linespoints

set output "experiment18/bank-b.eps"
plot "experiment18/agents-bank/Cheating_1" title "Cheating_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment18/agents-bank/Connected" title "Connected" with yerrorbars, "" smooth csplines notitle,\
     "experiment18/agents-bank/ForTrust" title "ForTrust" with yerrorbars, "" smooth csplines notitle,\
     "experiment18/agents-bank/FordPrefect" title "FordPrefect" with yerrorbars, "" smooth csplines notitle,\
     "experiment18/agents-bank/Honest_1" title "Honest_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment18/agents-bank/Honest_2" title "Honest_2" with yerrorbars, "" smooth csplines notitle,\
     "experiment18/agents-bank/Honest_3" title "Honest_3" with yerrorbars, "" smooth csplines notitle,\
     "experiment18/agents-bank/Honest_4" title "Honest_4" with yerrorbars, "" smooth csplines notitle,\
     "experiment18/agents-bank/Next" title "Next" with yerrorbars, "" smooth csplines notitle,\
     "experiment18/agents-bank/Uno" title "Uno" with yerrorbars, "" smooth csplines notitle
