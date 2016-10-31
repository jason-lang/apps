#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "money"
set key top left
set terminal postscript eps color enhanced
set output "experiment15/bank-a.eps"
plot "experiment15/agents-bank/Cheating_1" title "Cheating_1" with linespoints,\
     "experiment15/agents-bank/Connected" title "Connected" with linespoints,\
     "experiment15/agents-bank/ForTrust" title "ForTrust" with linespoints,\
     "experiment15/agents-bank/FordPrefect" title "FordPrefect" with linespoints,\
     "experiment15/agents-bank/Next" title "Next" with linespoints,\
     "experiment15/agents-bank/Uno" title "Uno" with linespoints

set output "experiment15/bank-b.eps"
plot "experiment15/agents-bank/Cheating_1" title "Cheating_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment15/agents-bank/Connected" title "Connected" with yerrorbars, "" smooth csplines notitle,\
     "experiment15/agents-bank/ForTrust" title "ForTrust" with yerrorbars, "" smooth csplines notitle,\
     "experiment15/agents-bank/FordPrefect" title "FordPrefect" with yerrorbars, "" smooth csplines notitle,\
     "experiment15/agents-bank/Next" title "Next" with yerrorbars, "" smooth csplines notitle,\
     "experiment15/agents-bank/Uno" title "Uno" with yerrorbars, "" smooth csplines notitle
