package test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import jason.environment.grid.Location;

import org.junit.Before;
import org.junit.Test;

import arch.LocalWorldModel;
import env.WorldModel;


public class TestWorldModel  {

    LocalWorldModel model;
    
    @Before
    public void scenario() {
        model = new LocalWorldModel(50,50, WorldModel.agsByTeam, null);
        //model.setCorral(new Location(0,49), new Location(2,49));
        //model.wall(7, 44, 7, 49);
    }

    @Test
    public void testIsFree() {
        Location l = new Location(10,10);
        assertTrue(model.isFree(l));
        model.add(WorldModel.OBSTACLE, l);
        assertFalse(model.isFree(l));
        model.add(WorldModel.ENEMYCORRAL,l);
        assertFalse(model.isFree(l));
        
        l = new Location(10,11);
        assertTrue(model.isFree(l));
        model.add(WorldModel.ENEMYCORRAL,l);
        assertTrue(model.hasObject(WorldModel.ENEMYCORRAL, l));
        
        assertFalse(model.isFree(l));
        model.add(WorldModel.OBSTACLE, l);
        assertFalse(model.isFree(l));
        
        assertTrue(model.hasObject(WorldModel.OBSTACLE, l));
        assertTrue(model.hasObject(WorldModel.ENEMYCORRAL, l));
    }

}
