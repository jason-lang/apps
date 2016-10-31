package test;

import static org.junit.Assert.assertEquals;
import jason.asSyntax.Literal;

import org.junit.Test;

import agent.UniqueBelsBB;


public class TestUniqueBB  {

    @Test
    public void removeOldBB() {
        UniqueBelsBB bb = new UniqueBelsBB();
        bb.add(Literal.parseLiteral("cow(1,1,1)[step(3),step(1),step(6)]"));
        bb.add(Literal.parseLiteral("cow(2,1,1)[step(10),step(1),step(6)]"));
        bb.add(Literal.parseLiteral("cow(3,1,1)"));
        
        bb.remove_old_bels(Literal.parseLiteral("cow(1,1,1)"), "step", 4, 11);
        
        assertEquals(2, bb.size());
        
        bb.remove_old_bels(Literal.parseLiteral("cow(1,1,1)"), "step", 4, 12);
        bb.remove_old_bels(Literal.parseLiteral("cow(1,1,1)"), "step", 4, 15);
        assertEquals(1, bb.size());
    }
}
