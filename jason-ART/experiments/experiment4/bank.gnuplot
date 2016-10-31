#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "money"
set key top left
set terminal postscript eps color enhanced
set output "experiment4/bank-a.eps"
plot "experiment4/agents-bank/Cheating_1" title "Cheating_1" with linespoints,\
     "experiment4/agents-bank/Cheating_2" title "Cheating_2" with linespoints,\
     "experiment4/agents-bank/ForTrust" title "ForTrust" with linespoints,\
     "experiment4/agents-bank/Lazy_1" title "Lazy_1" with linespoints,\
     "experiment4/agents-bank/Lazy_2" title "Lazy_2" with linespoints,\
     "experiment4/agents-bank/Simple_1" title "Simple_1" with linespoints,\
     "experiment4/agents-bank/Simple_2" title "Simple_2" with linespoints

set output "experiment4/bank-b.eps"
plot "experiment4/agents-bank/Cheating_1" title "Cheating_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment4/agents-bank/Cheating_2" title "Cheating_2" with yerrorbars, "" smooth csplines notitle,\
     "experiment4/agents-bank/ForTrust" title "ForTrust" with yerrorbars, "" smooth csplines notitle,\
     "experiment4/agents-bank/Lazy_1" title "Lazy_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment4/agents-bank/Lazy_2" title "Lazy_2" with yerrorbars, "" smooth csplines notitle,\
     "experiment4/agents-bank/Simple_1" title "Simple_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment4/agents-bank/Simple_2" title "Simple_2" with yerrorbars, "" smooth csplines notitle
