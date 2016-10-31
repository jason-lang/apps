// ag1 in project testRemPlan.mas2j
demo.
@d1 +demo : true 
   <- .print("this program should print 'in plan l1', 'in plan l2 *'");
      !g1;
      .remove_plan(l1);
      !g1.
   
@l1 +!g1 : true <- .print("in plan l1"). //; -demo; +demo.
@l2 +!g1 : true <- .print("in plan l2 *").

