package jason.eis;

import jason.JasonException;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.ListTerm;
import jason.asSyntax.ListTermImpl;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.StringTerm;
import jason.asSyntax.Structure;
import jason.asSyntax.Term;

import java.util.ArrayList;
import java.util.Collection;

import eis.iilang.Action;
import eis.iilang.Function;
import eis.iilang.Identifier;
import eis.iilang.Numeral;
import eis.iilang.Parameter;
import eis.iilang.ParameterList;
import eis.iilang.Percept;
 
/**
 * Translate EIS data to Jason data and vice-versa
 * 
 * @author Jomi
 */
public class Translator {

    public static Literal perceptToLiteral(Percept per) throws JasonException {
        Literal l = ASSyntax.createLiteral(per.getName());
        for (Parameter par: per.getParameters())
            l.addTerm(parameterToTerm(par));
        return l;
    }

    public static Percept literalToPercept(jason.asSyntax.Literal l) {
        Percept p = new Percept(l.getFunctor());
        for (Term t: l.getTerms())
            p.addParameter( termToParameter(t) );
        return p;
    }

    public static Action literalToAction(Literal action) {
        Parameter[] pars = new Parameter[action.getArity()];
        for (int i=0; i<action.getArity(); i++)
            pars[i] = termToParameter(action.getTerm(i));            
        return new Action(action.getFunctor(), pars);
    }
    
    public static Structure actoinToStructure(Action action) throws JasonException {
        Structure s = ASSyntax.createStructure(action.getName());
        for (Parameter par: action.getParameters())
            s.addTerm(parameterToTerm(par));
        return s;
    }
    
    
    public static Parameter termToParameter(Term t) {
        if (t.isNumeric()) {
            return new Numeral( ((NumberTerm)t).solve() );
        } else if (t.isList()) {
            Collection<Parameter> terms = new ArrayList<Parameter>();
            for (Term listTerm: (ListTerm)t)
                terms.add(termToParameter(listTerm));
            return new ParameterList( terms );
        } else if (t.isString()) {
            return new Identifier( ((StringTerm)t).getString() );            
        } else if (t.isLiteral()) {
            Literal l = (Literal)t;
            if (! l.hasTerm()) {
                return new Identifier(l.getFunctor());
            } else {
                Parameter[] terms = new Parameter[l.getArity()];
                for (int i=0; i<l.getArity(); i++)
                    terms[i] = termToParameter(l.getTerm(i));
                return new Function( l.getFunctor(), terms );
            }
        }
        return new Identifier(t.toString());            
    }
    
    public static Term parameterToTerm(Parameter par) throws JasonException {
        if (par instanceof Numeral) {
            return ASSyntax.createNumber(((Numeral)par).getValue().doubleValue());
        } else if (par instanceof Identifier) {
            try {
                Identifier i = (Identifier)par;
                String a = i.getValue();
                if (!Character.isUpperCase(a.charAt(0)))
                    return ASSyntax.parseTerm(a);
            } catch (Exception e) {
            }
            return ASSyntax.createString(((Identifier)par).getValue());
        } else if (par instanceof ParameterList) {
            ListTerm list = new ListTermImpl();
            ListTerm tail = list;
            for (Parameter p: (ParameterList)par)
                tail = tail.append( parameterToTerm(p) );
            return list;
        } else if (par instanceof Function) {
            Function f = (Function)par;
            Structure l = ASSyntax.createStructure(f.getName());
            for (Parameter p: f.getParameters())
                l.addTerm(parameterToTerm(p));
            return l;
        } 
        throw new JasonException("The type of parameter "+par+" is unknown!");
    }
}
