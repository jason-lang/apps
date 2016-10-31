test_rule(A,A).

!test1.
+!test1 <-
     // Create a dummy local variable
     A = test_wrong_value;
     ?test_rule(Test,test_right_value);
     .println("Test = ",Test).

!test(test_wrong_value).
+!test(A) : test_rule(Test,test_right_value) <- .println("Test = ",Test).
