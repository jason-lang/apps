package agent;

import jason.asSemantics.Agent;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.InternalActionLiteral;
import jason.asSyntax.Literal;
import jason.asSyntax.Plan;
import jason.asSyntax.PlanBody;
import jason.asSyntax.PlanBodyImpl;
import jason.asSyntax.Pred;
import jason.asSyntax.directives.Directive;

import java.util.logging.Level;
import java.util.logging.Logger;

/** directive used to generate maintenance goals related to organisational/ciclic goals */
public class OrgMaintenanceGoal implements Directive {

    static Logger logger = Logger.getLogger(OrgMaintenanceGoal.class.getName());
    
    public Agent process(Pred directive, Agent outerContent, Agent innerContent) {
        try {
            Agent newAg = new Agent();
            newAg.initAg();
            
            PlanBodyImpl endofplan = null;
            Literal  goal = null;
            
            //ListTerm annots = ListTermImpl.parseList("[scheme(SchId),mission(MissionId),group(GroupId)]");
            
            // change all inner plans
            for (Plan p: innerContent.getPL()) {
                // create end of plan: .wait
                InternalActionLiteral wait = new InternalActionLiteral(".wait");
                wait.addTerm(directive.getTerm(0));
                endofplan = new PlanBodyImpl(PlanBody.BodyType.internalAction, wait);

                // create end of plan: !!goal[.....]
                //p.getTrigger().getLiteral().addAnnots( (ListTerm)annots.clone());
                goal = p.getTrigger().getLiteral().copy();
                endofplan.add(new PlanBodyImpl(PlanBody.BodyType.achieveNF, goal));

                // add in the end of plan
                p.getBody().add(endofplan);
                newAg.getPL().add(p, false);
            }
                
            // add failure plan:
            //    -!goto_near_unvisited[scheme(Sch),mission(Mission)]
            //        <- .current_intention(I);
            //           .print("ooo Failure to goto_near_unvisited ",I);
            //           .wait("+pos(_,_,_)"); // wait next cycle
            //           !!goto_near_unvisited[scheme(Sch),mission(Mission)].
            goal = goal.copy();
            goal.addAnnot(ASSyntax.parseStructure("error(EID)"));
            goal.addAnnot(ASSyntax.parseStructure("error_msg(EMsg)"));
            //goal.addAnnot(ASSyntax.parseStructure("code_line(ELine)"));
            String sp = "-!"+goal+" <- .current_intention(I); " +
                              ".println(\"ooo Failure in organisational goal "+goal.getFunctor()+": \", EID, \" -- \", EMsg); "+
                              ".println(\"ooo intention is \",I); "+
                              endofplan + ".";
            Plan p = ASSyntax.parsePlan(sp);
            newAg.getPL().add(p);
            return newAg;
        } catch (Exception e) {
            logger.log(Level.SEVERE,"OrgMaintenanceGoal directive error.", e);
        }
        return null;
    }
}
