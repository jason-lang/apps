Jason Logic Engine 
----------------------

it is a sub set of classes of Jason intended to be used
as a logic engine (+- like a Prolog engine)

you find same examples of use in src directory and API
documentation in doc directory. Main classes to see are
- ASSyntax
- Unifier
- Literal

to compile and run examples:
   cd src
   javac -cp ../lib/jason-le.jar:. examples/*.java
   java  -cp ../lib/jason-le.jar:. examples.UnifierDemo1
   java  -cp ../lib/jason-le.jar:. examples.UnifierDemo2
   java  -cp ../lib/jason-le.jar:. examples.EngineDemo1

the source code of the Jason classes are available on
   https://sourceforge.net/projects/jason/


by
Jomi & Rafael 2009


---------------------------------------------------------------------------
Copyright (C) 2009   Jomi F. Hubner, Rafael H. Bordini
Jason-LE is distributed under LGPL. See file LGPL.txt in this directory.

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

To contact the authors:
jomifred@gmail.com
r.bordini@acm.org
---------------------------------------------------------------------------
