!ns::start1(10).

+!ns::start1(X)
   <- .print(ini);
      .drop_intention(ns::start1(X));
      .print(end).
