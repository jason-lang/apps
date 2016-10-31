#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set xrange [0:19]
set ylabel "money"
set key top left
set terminal postscript eps enhanced color 18
set output "experiments/experiment17/bank-a.eps"
plot "experiments/experiment17/agents-bank/Cheating" title "Cheating" lc "black" with linespoints,\
     "experiments/experiment17/agents-bank/Connected" title "Connected" lc "black" with linespoints,\
     "experiments/experiment17/agents-bank/ForTrust" title "ForTrust" lc "black" with linespoints,\
     "experiments/experiment17/agents-bank/FordPrefect" title "FordPrefect" lc "black" with linespoints,\
     "experiments/experiment17/agents-bank/Honest" title "Honest" lc "black" with linespoints,\
     "experiments/experiment17/agents-bank/Next" title "Next" lc "black" with linespoints,\
     "experiments/experiment17/agents-bank/Uno" title "Uno" lc "black" with linespoints

set output "experiments/experiment17/bank-b.eps"
plot "experiments/experiment17/agents-bank/Cheating" title "Cheating" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment17/agents-bank/Connected" title "Connected" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment17/agents-bank/ForTrust" title "ForTrust" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment17/agents-bank/FordPrefect" title "FordPrefect" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment17/agents-bank/Honest" title "Honest" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment17/agents-bank/Next" title "Next" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment17/agents-bank/Uno" title "Uno" with yerrorbars, "" smooth csplines notitle
