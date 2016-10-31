package test;

import jason.asSemantics.Agent;
import jason.asSyntax.Literal;
import junit.framework.TestCase;
import agent.UniqueBelsBB;

public class UniqueBBTest extends TestCase {

	UniqueBelsBB bb;
	Literal initialSize = Literal.parseLiteral("gsize(1,2,3)");
	Literal initialAlloc1 = Literal.parseLiteral("allocated(1,jomi)");
	Literal initialAlloc2 = Literal.parseLiteral("allocated(1,rafa)");
	Literal initialTest = Literal.parseLiteral("test(a,b,c)");
	
	@Override
	protected void setUp() throws Exception {
		bb = new UniqueBelsBB();
		bb.init(new Agent(), new String[] {"gsize(_,_,_)", "allocated(_,key)", "test(key,_,key)"} );
		bb.add(initialSize);
		bb.add(initialAlloc1);
		bb.add(initialAlloc2);
		bb.add(initialTest);
	}

	/*
	public void testchangeNotKeyTermForUnNamedVar() {
		Literal l = bb.changeNotKeyTermForUnNamedVar(Literal.parseLiteral("gsize(a,40,50)"));
		assertEquals(l.toString(), "gsize(_,_,_)");
		
		l = bb.changeNotKeyTermForUnNamedVar(Literal.parseLiteral("allocated(a,marcos)"));
		assertEquals(l.toString(), "allocated(_,marcos)");

		l = bb.changeNotKeyTermForUnNamedVar(Literal.parseLiteral("test(a,b,c)"));
		assertEquals(l.toString(), "test(a,_,c)");
	}
	*/

	public void testAddLiteral() {
		bb.add(Literal.parseLiteral("gsize(4,5,6)"));
		assertTrue(bb.contains(initialSize) == null);

		bb.add(Literal.parseLiteral("allocated(5,jomi)"));
		bb.add(Literal.parseLiteral("allocated(8,jomi)"));
		bb.add(Literal.parseLiteral("allocated(3,rafa)"));
		Literal alloc3 = Literal.parseLiteral("allocated(3,roque)");
		bb.add(alloc3);
		
		assertTrue(bb.contains(initialAlloc1) == null);
		assertTrue(bb.contains(initialAlloc2) == null);
		assertTrue(bb.contains(alloc3) != null);

		bb.add(Literal.parseLiteral("test(1,2,3)"));
		bb.add(Literal.parseLiteral("test(a,e,c)"));
		assertTrue(bb.contains(initialTest) == null);
		
		assertEquals(bb.size(),6);
	}

}
