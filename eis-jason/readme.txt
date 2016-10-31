Jason Integration with Environment Interface Standard (EIS)
-----------------------------------------------------------

        Jason   http://jason.sf.net
        EIS     http://cig.in.tu-clausthal.de/eis


This package provides adapters that can 'wrap' both 
a) environments developed as defined in the  EIS to be used 
   as a Jason environment; and
b) environments developed as defined in Jason to be used
   as an EIS environment.

See the doc directory for more information about how to 
use this package.

** Examples

* EIS -> Jason

Two examples, based on the Carriage environment provided with
EIS, are included in this package:

1. Two Jason agents controlling each one a robot

2. One Jason agent controlling both robots

To run the examples, open the corresponding projects
(Carriage-2agents.mas2j and Carriage-1agent.mas2j) in JasonIDE
and start them. Or use Ant
    ant run1
for the first example, and
    ant run2
for the second.

* Jason -> EIS

The environment of the domestic-robot example of Jason is EISificated.
See examples/domestic-robot for more information.

to run:
    cd examples/domestic-robot
    ant run

** Requirements

. Jason >= 1.3.4 (jason.jar of this release is included in this package)


** Source

All source code is provided under LGPL and is available in the src
directory.

--
by
Jomi F. Hubner 2011

