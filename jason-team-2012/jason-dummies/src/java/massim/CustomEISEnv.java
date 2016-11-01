package massim;

import jason.asSyntax.Literal;
import jason.eis.EISAdapter;

import java.util.List;


public class CustomEISEnv extends EISAdapter {

    @Override
    protected List<Literal> addEISPercept(List<Literal> percepts, String ag) {
        return percepts;
    }
}
