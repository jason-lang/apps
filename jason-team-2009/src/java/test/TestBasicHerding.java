package test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import jason.environment.grid.Location;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import jia.Search;
import jia.Vec;
import jia.cluster;
import jia.herd_position;
import jia.other_side_fence;
import jia.scouter_pos;
import jia.herd_position.Formation;

import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

import arch.LocalWorldModel;
import busca.Nodo;
import env.WorldModel;

public class TestBasicHerding {

    Vec cowboy;
    LocalWorldModel model;
    
    @Before
    public void scenario() {
        model = new LocalWorldModel(50,50, WorldModel.agsByTeam, null);
        model.setCorral(new Location(0,49), new Location(2,49));
        model.wall(7, 44, 7, 49);
    }
    
    public void scenario1() {
        cowboy = new Vec(3,5);
        model.add(WorldModel.AGENT, cowboy.getLocation(model));

        addCowsToModel(
                new Vec(6,7),
                new Vec(5,30),
                new Vec(4,8),
                new Vec(5,10),
                new Vec(2,0));
                //new Vec(0,1));
    }
    
    public void scenario2() {
        cowboy = new Vec(11,3);
        model.add(WorldModel.AGENT, cowboy.getLocation(model));
        
        addCowsToModel(
                new Vec(8,0),
                new Vec(9,0),
                new Vec(10,0),
                new Vec(8,1),
                new Vec(9,1),
                new Vec(10,1),
                new Vec(8,2),
                new Vec(9,2),
                new Vec(10,2));
    }

    public void scenario3() {
        model = new LocalWorldModel(50,19, WorldModel.agsByTeam, null);
        model.setCorral(new Location(8,0), new Location(12,2));
        model.wall(7, 0, 7, 2);
        cowboy = new Vec(10,12);
        model.add(WorldModel.AGENT, cowboy.getLocation(model));
        
        addCowsToModel(
                new Vec(1,16),
                new Vec(2,14),
                new Vec(3,13),
                new Vec(5,14),
                new Vec(6,12),
                new Vec(6,13),
                new Vec(20,2),
                new Vec(20,3),
                new Vec(20,4));
    }

    public void scenario4() { // with fence
        addFenceToModel(
                new Vec(18,0),
                new Vec(18,1),
                new Vec(18,2),
                new Vec(18,3),
                new Vec(18,4),
                new Vec(18,5),
                new Vec(18,6));
                //new Vec(0,1));
        model.add(WorldModel.SWITCH, 18, 42);
    }

    @Test
    public void bigCluster() throws Exception {
        // big cluster
        for (int x = 10; x < 30; x++) {
            for (int y = 5; y < 20; y++) {
                addCowsToModel(new Vec(model,x,y));
            }
        }
        
        List<Location> cowsl = cluster.getCluster(model, WorldModel.cowPerceptionRatio, null);
        assertEquals(cluster.MAXCLUSTERSIZE, cowsl.size());
    }

    private void addCowsToModel(Vec... cows) {
        for (int i=0; i<cows.length; i++) {
            Location l = cows[i].getLocation(model);
            model.addKnownCow(l.x, l.y);
        }
    }
    
    private void addFenceToModel(Vec... fences) {
        for (int i=0; i<fences.length; i++) {
            Location l = fences[i].getLocation(model);
            model.add(WorldModel.CLOSED_FENCE, l.x, l.y);
        }
    }
    
    @Test
    public void testVec() {
        scenario1();
        //assertEquals(new Vec(6,7), cow.add(cowboy));
        //assertEquals(new Location(6,42), cow.add(cowboy).getLocation(model));
        assertEquals(new Location(3,44), cowboy.getLocation(model));
        assertEquals(new Location(1,49), model.getCorral().center());
        assertEquals(new Vec(3,2), new Vec(6,7).sub(cowboy)); //new Vec(model, cowboy.getLocation(model), cow.add(cowboy).getLocation(model)));
        Vec v = new Vec(3,2);
        assertEquals(v, v.newAngle(v.angle()));
    }
    
    @Test
    public void testOtherSideFence() throws Exception {
        scenario4();
        assertTrue( model.hasObject( WorldModel.FENCE, new Vec(18,2).getLocation(model)) );
        
        Vec start = new Vec(model, 15, 45);
        Vec fence = new Vec(model, 18, 45);
        Vec target = new other_side_fence().computesOtherSide(model, start, fence);
        
        assertEquals(new Location(21,45), target.getLocation(model));

        start = new Vec(model, 10, 42);
        fence = new Vec(model, 18, 45);
        target = new other_side_fence().computesOtherSide(model, start, fence);
        
        assertEquals(new Location(26,48), target.getLocation(model));
    
        start = new Vec(model, 17, 44);
        fence = new Vec(model, 18, 45);
        target = new other_side_fence().computesOtherSide(model, start, fence);
        assertEquals(new Location(19,46), target.getLocation(model));
    }
    
    @Test 
    public void testVecSort() {
        scenario1();
        
        List<Vec> cowsl = new ArrayList<Vec>(model.getKnownCows());
        Collections.sort(cowsl);
        assertEquals(new Vec(2,0), cowsl.get(0));
        assertEquals(new Vec(4,8), cowsl.get(1));
        assertEquals(new Vec(6,7), cowsl.get(2));
        assertEquals(new Vec(5,10), cowsl.get(3));
        assertEquals(new Vec(5,30), cowsl.get(4));
    }

    @Test
    public void testCowsRepMat() throws Exception {
        scenario1();
        assertEquals(2, model.getCowsRep(5,38));
        assertEquals(1, model.getCowsRep(5,37));
        assertEquals(0, model.getCowsRep(5,36));
        assertEquals(5, model.getCowsRep(5,40));
    }

    @Test
    public void testAgsRepMat() throws Exception {
        scenario1();
        //assertEquals(4, model.getAgsRep(3,43));
        //assertEquals(2, model.getAgsRep(5,42));
        //assertEquals(0, model.getAgsRep(6,42));
        
        model.add(WorldModel.ENEMY, 4, 44);
        /*
        assertEquals(4, model.getAgsRep(3,43));
        assertEquals(2, model.getAgsRep(5,42));
        assertEquals(2, model.getAgsRep(6,42));
        */
        
        model.remove(WorldModel.ENEMY, 4, 44);
        /*assertEquals(4, model.getAgsRep(3,43));
        assertEquals(2, model.getAgsRep(5,42));
        assertEquals(0, model.getAgsRep(6,42));

        model.remove(WorldModel.AGENT, cowboy.getLocation(model));
        */
        /*
        assertEquals(0, model.getAgsRep(3,43));
        assertEquals(0, model.getAgsRep(5,42));
        assertEquals(0, model.getAgsRep(6,42));
        */
        assertEquals(2, model.getObsRep(6, 44));
        assertEquals(1, model.getObsRep(7, 43));
        assertEquals(0, model.getObsRep(5, 44));
    }

    @Test
    public void testAStar1() throws Exception {
        scenario1();
        Search s = new Search(model, cowboy.getLocation(model), new Location(8,37), null, true, true, true, false, false, false, null);
        Nodo path = s.search();
        assertEquals(13, Search.normalPath(path).size());
    }

    @Test
    public void testAStar2() throws Exception {
        scenario1();
        model.add(WorldModel.CLOSED_FENCE, 0,40);
        model.add(WorldModel.CLOSED_FENCE, 1,40);
        model.add(WorldModel.CLOSED_FENCE, 2,40);
        model.add(WorldModel.CLOSED_FENCE, 3,40);
        model.add(WorldModel.CLOSED_FENCE, 4,40);
        Search s = new Search(model, cowboy.getLocation(model), new Location(8,37), null, true, true, true, false, false, true, null);
        Nodo path = s.search();
        assertEquals(11, Search.normalPath(path).size());

        // because of fence cost, also choose the same path of fence as obstacle
        s = new Search(model, cowboy.getLocation(model), new Location(8,37), null, true, true, true, false, false, false, null);
        path = s.search();
        assertEquals(11, Search.normalPath(path).size());
    
    }

    @Test
    public void testAStarPathInEnemyCorral() throws Exception {
        scenario3();
        model.add(WorldModel.ENEMYCORRAL, 10, 7);
        model.add(WorldModel.ENEMYCORRAL, 11, 7);
        model.add(WorldModel.ENEMYCORRAL, 12, 7);
        Search s = new Search(model,new Location(12,12), new Location(10,1), null, true, false, true, false, true, false, null);
        Nodo path = s.search();
        //System.out.println(s.normalPath(path));
        assertTrue(Search.normalPath(path).size() > 10);
    }

    @Test
    public void moveCows2() throws Exception {
        scenario1();
        
        // find center/clusterise
        List<Location> clusterLocs = cluster.getCluster(model, WorldModel.cowPerceptionRatio, null);
        List<Vec> cowsl = cluster.location2vec(model, clusterLocs);
        //Vec stddev = Vec.stddev(cowsl, Vec.mean(cowsl));
        assertEquals(3, cowsl.size());
        
        Vec mean   = Vec.mean(cowsl);
        assertEquals(new Vec(5,8), mean);
        
        //Search s = new Search(model, mean.getLocation(model), model.getCorralCenter(), null, false, false, false, true, null);
        //List<Nodo> np = s.normalPath(s.search());

        int stepsFromCenter = (int)Math.round(Vec.max(cowsl).sub(mean).magnitude())+1;
        assertEquals(3, stepsFromCenter);
        
        herd_position hp = new herd_position();
        hp.setModel(model);
        
        Location byIA =  hp.getAgTarget(clusterLocs, Formation.one, cowboy.getLocation(model));
        assertEquals(new Location(6,38), byIA);

        assertEquals("[6,38, 8,40, 3,38, 9,44, 0,39]", hp.formationPlaces(clusterLocs, Formation.five).toString());
        
        byIA =  hp.getAgTarget(clusterLocs, Formation.six, cowboy.getLocation(model));
        assertEquals(new Location(8,39), byIA);

        assertEquals("[8,39, 5,38, 8,43, 1,39, 8,45, 0,41]", hp.formationPlaces(clusterLocs, Formation.six).toString());

        /*
        // add an agent in 6,39
        model.add(WorldModel.AGENT, 6,39);
        byIA =  hp.getAgTarget(clusterLocs, Formation.six, cowboy.getLocation(model));
        assertEquals(new Location(5,38), byIA);        

        // add an agent in 5,38
        model.add(WorldModel.AGENT, 5,38);
        byIA =  hp.getAgTarget(clusterLocs, Formation.six,cowboy.getLocation(model));
        assertEquals(new Location(7,42), byIA);        

        // add an agent in 7,42
        model.add(WorldModel.AGENT, 7,42);
        byIA =  hp.getAgTarget(clusterLocs, Formation.six,cowboy.getLocation(model));
        assertEquals(new Location(4,38), byIA);        

        // add an agent in 4,38
        model.add(WorldModel.AGENT, 4,38);
        byIA =  hp.getAgTarget(clusterLocs, Formation.six,cowboy.getLocation(model));
        //assertEquals(null, byIA);        

        // add an agent in 5,37
        //model.add(WorldModel.AGENT, 5,37);
        //byIA =  new herd_position().getAgTarget(model, Formation.six,cowboy.getLocation(model));
        //assertEquals(new Location(5,37), byIA);
         */
    }

    @Test 
    public void moveCows3() throws Exception {
        scenario2();
        model.add(WorldModel.ENEMY, 11,48);

        List<Location> clusterLocs = cluster.getCluster(model, WorldModel.cowPerceptionRatio, null);
        List<Vec> cowsl = cluster.location2vec(model, clusterLocs);
        assertEquals(9, cowsl.size());
        
        herd_position hp = new herd_position();
        hp.setModel(model);
        
        Location byIA =  hp.getAgTarget(clusterLocs, Formation.one, cowboy.getLocation(model));
        assertEquals(new Location(11,49), byIA);

        List<Location> form =  hp.formationPlaces(clusterLocs, Formation.four);
        assertTrue(form.contains(new Location(11,49)));
        assertTrue(form.contains(new Location(6,49)));
        //assertTrue(form.contains(new Location(3,48)));
        //assertTrue(form.contains(new Location(15,48)));
    }

    @Test @Ignore
    public void formationSc3() throws Exception {
        scenario3();

        List<Location> clusterLocs = cluster.getCluster(model, WorldModel.cowPerceptionRatio, null);
        assertEquals(6, clusterLocs.size());

        herd_position hp = new herd_position();
        hp.setModel(model);

        List<Location> form =  hp.formationPlaces(clusterLocs, Formation.four);
        assertTrue(form.contains(new Location(0,4)) || form.contains(new Location(0,3)));
        assertTrue(form.contains(new Location(0,8)));
        assertTrue(form.contains(new Location(0,1)) || form.contains(new Location(0,0)));
        assertTrue(form.contains(new Location(4,11)));
    }

    @Test 
    public void scouterPos() throws Exception {
        scenario1();
        Location byIA =  new scouter_pos().getScouterTarget(model, new Location(2,46), new Location(5,44));
        assertEquals(new Location(6,46), byIA);

        byIA =  new scouter_pos().getScouterTarget(model, new Location(9,46), new Location(9,42));
        assertEquals(new Location(22,42), byIA);
    }

    /*
    @Test
    public void oneCow() throws Exception {
        // get the location the cow should go
        Location cowLocation = cow.getLocation(model);

        // search cow desired location
        Search s = new Search(model, cowLocation, model.getCorralCenter(), null, false, false, false, null);
        Nodo path = s.search();
        assertEquals(8, path.g()); //firstAction(path));
        
        // cow target in direction to corral
        Location cowTarget = WorldModel.getNewLocationForAction(cowLocation, s.firstAction(path));
        //assertEquals(new Location(5,43), cowTarget);
        Vec cowVecTarget = new Vec(model, cowTarget);
        //assertEquals(new Vec(5,6), cowVecTarget);
        
        // agent target to push cow into corral
        Vec agVecTarget = cow.sub(cowVecTarget).product(2).add(cow);
        Location agTarget = agVecTarget.getLocation(model);
        //assertEquals(new Location(8,40), agTarget);
        
        s = new Search(model, cowboy.getLocation(model), agTarget, null, true, true, true, null);
        path = s.search();
        System.out.println(path.g() + " " + path.montaCaminho());
        assertEquals(12, path.g());
    }
    */

    
    /*
    @Test
    public void moveCows1() throws Exception {
        // get the location the cows should go
        List<Vec> cowsTarget = new ArrayList<Vec>(); 
        for (int i=0; i<cows.length; i++) {
            Search s = new Search(model, cows[i].getLocation(model), model.getCorralCenter(), null, false, false, false, null);
            Location cowTarget = WorldModel.getNewLocationForAction(cows[i].getLocation(model), s.firstAction(s.search()));
            cowsTarget.add(new Vec(model, cowTarget));
        }
        //System.out.println(cowsTarget);
        
        Vec stddev = Vec.stddev(cowsTarget);
        assertEquals(new Vec(0,9), stddev);
        
        // remove max if stddev is too big
        while (stddev.magnitude() > 3) {
            cowsTarget.remove(Vec.max(cowsTarget));
            stddev = Vec.stddev(cowsTarget);
        }
        assertTrue(stddev.magnitude() < 3);
        
        Vec mean   = Vec.mean(cowsTarget);
        assertEquals(new Vec(5,7), mean);
        double incvalue = (Vec.max(cowsTarget).sub(mean).magnitude()+2) / mean.magnitude();
        //System.out.println( incvalue);
        Vec agTarget = mean.product(incvalue+1);
        //System.out.println(agTarget);
        assertEquals(new Vec(7,10), agTarget);

        Location byIA =  new herd_position().getAgTarget(model);
        assertEquals(byIA, agTarget.getLocation(model));
        
        Search s = new Search(model, cowboy.getLocation(model), agTarget.getLocation(model), null, true, true, true, null);
        Nodo path = s.search();
        //System.out.println(path.g() + " " + path.montaCaminho());
        assertEquals(14, path.g());
    }
    */

    /*
    @Test
    public void moveCows2() throws Exception {
        scenario1();
        
        List<Vec> cowsTarget = new ArrayList<Vec>(); 
        for (int i=0; i<cows.length; i++) {
            cowsTarget.add(cows[i]);
        }

        // find center/clusterise
        cowsTarget = Vec.cluster(cowsTarget, 2);
        Vec stddev = Vec.stddev(cowsTarget);
        assertTrue(stddev.magnitude() < 3);
        
        Vec mean   = Vec.mean(cowsTarget);
        assertEquals(new Vec(5,8), mean);
        
        int stepsFromCenter = (int)Vec.max(cowsTarget).sub(mean).magnitude()+1;
        assertEquals(3, stepsFromCenter);
        
        // run A* to see the cluster target in n steps
        Search s = new Search(model, mean.getLocation(model), model.getCorralCenter(), null, false, false, false, null);
        List<Nodo> np = s.normalPath(s.search());
        int n = Math.min(stepsFromCenter, np.size());
        assertEquals(3, n);

        Vec ctarget = new Vec(model, s.getNodeLocation(np.get(n)));
        assertEquals(new Vec(3,5), ctarget);
        
        Vec agTarget = mean.sub(ctarget).product(1.0).add(mean);
        assertEquals(new Vec(7,11), agTarget);
        
        Location byIA =  new herd_position().getAgTarget(model);
        assertEquals(byIA, agTarget.getLocation(model));
    }
    */
    

}
