#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "money"
set key top left
set terminal postscript eps color enhanced
set output "experiment10/bank-a.eps"
plot "experiment10/agents-bank/Cheating_1" title "Cheating_1" with linespoints,\
     "experiment10/agents-bank/ForTrust" title "ForTrust" with linespoints,\
     "experiment10/agents-bank/Lazy_1" title "Lazy_1" with linespoints,\
     "experiment10/agents-bank/Lazy_2" title "Lazy_2" with linespoints,\
     "experiment10/agents-bank/Simple_1" title "Simple_1" with linespoints,\
     "experiment10/agents-bank/Simple_2" title "Simple_2" with linespoints,\
     "experiment10/agents-bank/Simple_3" title "Simple_3" with linespoints,\
     "experiment10/agents-bank/Simple_4" title "Simple_4" with linespoints,\
     "experiment10/agents-bank/Simple_5" title "Simple_5" with linespoints,\
     "experiment10/agents-bank/Simple_6" title "Simple_6" with linespoints

set output "experiment10/bank-b.eps"
plot "experiment10/agents-bank/Cheating_1" title "Cheating_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment10/agents-bank/ForTrust" title "ForTrust" with yerrorbars, "" smooth csplines notitle,\
     "experiment10/agents-bank/Lazy_1" title "Lazy_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment10/agents-bank/Lazy_2" title "Lazy_2" with yerrorbars, "" smooth csplines notitle,\
     "experiment10/agents-bank/Simple_1" title "Simple_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment10/agents-bank/Simple_2" title "Simple_2" with yerrorbars, "" smooth csplines notitle,\
     "experiment10/agents-bank/Simple_3" title "Simple_3" with yerrorbars, "" smooth csplines notitle,\
     "experiment10/agents-bank/Simple_4" title "Simple_4" with yerrorbars, "" smooth csplines notitle,\
     "experiment10/agents-bank/Simple_5" title "Simple_5" with yerrorbars, "" smooth csplines notitle,\
     "experiment10/agents-bank/Simple_6" title "Simple_6" with yerrorbars, "" smooth csplines notitle
