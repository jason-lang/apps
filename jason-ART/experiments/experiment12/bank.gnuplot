#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
#set xrange [0:19]
set ylabel "money"
set key top left
set terminal postscript eps enhanced color 18
set output "experiments/experiment12/bank-a.eps"
plot "experiments/experiment12/agents-bank/Cheating_1" title "Cheating_1" with linespoints,\
     "experiments/experiment12/agents-bank/ForTrust" title "ForTrust" with linespoints,\
     "experiments/experiment12/agents-bank/Lazy_1" title "Lazy_1" with linespoints,\
     "experiments/experiment12/agents-bank/Lazy_2" title "Lazy_2" with linespoints,\
     "experiments/experiment12/agents-bank/Simple_1" title "Simple_1" with linespoints,\
     "experiments/experiment12/agents-bank/Simple_2" title "Simple_2" with linespoints,\
     "experiments/experiment12/agents-bank/Simple_3" title "Simple_3" with linespoints,\
     "experiments/experiment12/agents-bank/Simple_4" title "Simple_4" with linespoints

set output "experiments/experiment12/bank-b.eps"
plot "experiments/experiment12/agents-bank/Cheating_1" title "Cheating_1" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment12/agents-bank/ForTrust" title "ForTrust" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment12/agents-bank/Lazy_1" title "Lazy_1" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment12/agents-bank/Lazy_2" title "Lazy_2" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment12/agents-bank/Simple_1" title "Simple_1" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment12/agents-bank/Simple_2" title "Simple_2" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment12/agents-bank/Simple_3" title "Simple_3" with yerrorbars, "" smooth csplines notitle,\
     "experiments/experiment12/agents-bank/Simple_4" title "Simple_4" with yerrorbars, "" smooth csplines notitle
