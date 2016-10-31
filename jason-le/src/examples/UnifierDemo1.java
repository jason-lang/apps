package examples;

import static jason.asSyntax.ASSyntax.parseLiteral;
import jason.asSemantics.Unifier;
import jason.asSyntax.Literal;

/**

 This example show how to use the unifier
 
*/
public class UnifierDemo1 {
    public static void main(String[] args) throws Exception {

       // create some literals
       Literal utrecht = parseLiteral("city(\"Utrecht\", 100000, nl)");
       Literal stet    = parseLiteral("city(\"St Etienne\", 200000, fr)");
       
       // tries some unifications
       Literal r = parseLiteral("city(Name, Pop, Country)");
       
       // unifies utrecht and r
       Unifier u = new Unifier();
       System.out.println( u.unifies(utrecht, r) );     // true
       // print the unifier (that is a map from variables to terms)
       System.out.println(u);                           // {Name="Utrecht", Pop=100000, Country=nl}
       
       // the apply operation replaces variables by values of an unifier
       r.apply(u);
       System.out.println(r);                           // city("Utrecht",100000,nl)

       // unifies utrecht and stet
       u.clear();
       System.out.println( u.unifies(utrecht, stet) );  // false
    }
}
