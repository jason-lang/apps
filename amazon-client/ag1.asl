!search. // initial goal
+!search 
   <- .println("waiting amazon WebService...");
      amazon.search("Rafael Bordini", L);
      !print_list(L).
-!search
   <- .println("** failure in the access to the web service").
   
+!print_list([]).
+!print_list([H|T]) 
   <- !print_book(H); 
      !print_list(T).

+!print_book(book(ProductName, Authors, Price))
   <- .println; .println;
      .println(ProductName);
      .println("      by ", Authors);
      .println("      Price: ", Price).
