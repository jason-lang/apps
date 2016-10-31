package examples;

import static jason.asSyntax.ASSyntax.parseLiteral;
import static jason.asSyntax.ASSyntax.parseRule;
import jason.asSemantics.Agent;
import jason.asSemantics.Unifier;
import jason.asSyntax.Literal;
import jason.asSyntax.Rule;

import java.util.Iterator;

/**

 This example show how to use the Jason engine with rules
 
 (similar to EngineDemo1 but with a rule)
*/
public class RulesDemo1 {
    public static void main(String[] args) throws Exception {
        Literal utrecht = parseLiteral("city(\"Utrecht\", 100000, nl)");
        Literal stet    = parseLiteral("city(\"St Etienne\", 200000, fr)");
        
        Rule    good    = parseRule("good(X) :- city(X,H,C) & H < 150000.");
        
        // put those literals in a belief base
        Agent ag = new Agent();
        ag.initAg();
        ag.getBB().add(utrecht);
        ag.getBB().add(stet);
        ag.getBB().add(good); // add a rule
        
        // run a query
        // create the query using the parser
        Literal query = parseLiteral("good(City)");
        
        // get all solutions
        // a solution is a unifier for the query
        Iterator<Unifier> i = query.logicalConsequence(ag, new Unifier());
        while (i.hasNext()) {
            Unifier solution = i.next();
            Literal q = query.copy();
            q.apply(solution); // replace vars in 'q' by their values in 'solution'
            System.out.println(q);
        }
    }
}
