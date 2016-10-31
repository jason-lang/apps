#!/usr/bin/gnuplot -persist
set datafile separator ","
#set title "Simulation Result"
set xlabel "step"
set ylabel "money"
set key top left
set terminal postscript eps color enhanced
set output "experiment2/art-result-a.eps"
plot "experiment1/agents-bank/CheatingAgent_1" title "CheatingAgent_1" with linespoints,\
     "experiment1/agents-bank/CheatingAgent_2" title "CheatingAgent_2" with linespoints,\
     "experiment1/agents-bank/CheatingAgent_3" title "CheatingAgent_3" with linespoints,\
     "experiment1/agents-bank/ForTrust" title "ForTrust" with linespoints,\
     "experiment1/agents-bank/SimpleAgent_1" title "SimpleAgent_1" with linespoints,\
     "experiment1/agents-bank/SimpleAgent_2" title "SimpleAgent_2" with linespoints,\
     "experiment1/agents-bank/SimpleAgent_3" title "SimpleAgent_3" with linespoints,\
     "experiment1/agents-bank/SimpleAgent_4" title "SimpleAgent_4" with linespoints

set output "experiment2/art-result-b.eps"
plot "experiment1/agents-bank/CheatingAgent_1" title "CheatingAgent_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment1/agents-bank/CheatingAgent_2" title "CheatingAgent_2" with yerrorbars, "" smooth csplines notitle,\
     "experiment1/agents-bank/CheatingAgent_3" title "CheatingAgent_3" with yerrorbars, "" smooth csplines notitle,\
     "experiment1/agents-bank/ForTrust" title "ForTrust" with yerrorbars, "" smooth csplines notitle,\
     "experiment1/agents-bank/SimpleAgent_1" title "SimpleAgent_1" with yerrorbars, "" smooth csplines notitle,\
     "experiment1/agents-bank/SimpleAgent_2" title "SimpleAgent_2" with yerrorbars, "" smooth csplines notitle,\
     "experiment1/agents-bank/SimpleAgent_3" title "SimpleAgent_3" with yerrorbars, "" smooth csplines notitle,\
     "experiment1/agents-bank/SimpleAgent_4" title "SimpleAgent_4" with yerrorbars, "" smooth csplines notitle
