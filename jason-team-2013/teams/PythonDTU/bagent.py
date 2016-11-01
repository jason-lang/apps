#!/usr/bin/python3
import argparse
import pprint
import xml.etree.cElementTree as etree
import time
#import cPickle as pickle 
import pickle
from util import *
from algorithms import *
from comm import * 
from global_vars import *
import sys
from multiprocessing import Queue

class Runner(Graph, Algorithms):

    def __init__(self):
        self.prefix = args.prefix
        self.total_vertices = 300
        self.pickle = args.load_pickle
        self.weak_opp = args.weak_opp
        self.sim_backup = {'total_steps' : 0, 'id' : 1, 'time' : 0, 'runtime' : 0}
        self.ag_names = {}
        self.step = 0
        self.buy = args.buy
        self.do_attack = args.attack
        self.sim_id = -1
        self.initialized = 0
        self.percepts = []
	self.rolesListed = False #by smadas
        f = open(self.prefix[0]+"away.log", "w")
        f.close()

    def has_sab(self, vertex):
        match = self.has_opponent(vertex)      
        pot_sab = False
        for agent in match:
            if not agent in self.dis_opp and (not agent in self.opponents or self.opponents[agent] == 'Saboteur'):
                pot_sab = True
                break
        return pot_sab

    def has_opponent(self, v):
        if v.id in self.vertex_to_agent:
            return [x for x in self.vertex_to_agent[v.id] if self.prefix not in x]
        return []
    def initialize(self):
        self.vertices = {}
        self.initialized = 0
        self.max_sur = False
        self.known_edges = set()
        self.unknown_edges = set()
        self.vertex_to_agent = {}
        self.agent_to_vertex = {}
        self.owned = set()
        self.team_name = ''
        self.runtime = 0
        self.frontier = []
        self.opponents = {}
        self.dis_opp = set()
        self.max_opponent_strength = INITIAL_MAX_STRENGTH
        self.max_opponent_health = INITIAL_MAX_HEALTH
        self.money = 0
        
    def empty_queue(self):
        while True: 
            try:
                agent, message = self.q.get_nowait()
            except Exception as e:
                break
            self.handle(agent, message)
    def wait(self):
        self.empty_queue()
        if self.initialized < NUM_OF_AGENTS:
            while self.initialized < NUM_OF_AGENTS:
                self.empty_queue()

        while len(self.percepts) < NUM_OF_AGENTS:
            self.empty_queue()

    def timeit(self, method, *kwargs):
        s = time.time()
        res = method(*kwargs)
        print(str(method.__name__), time.time() - s)
        return res
    def handle(self, ag, message):
        agent = self.ag_names[ag]
        message = etree.fromstring(message)
        type = message.get('type')
        if 'auth-response' in type:
            if not  message.find('authentication').attrib['result'] == 'ok':
                raise Exception('Authentication failed')
            print(agent.name, 'authorized' + ' - ' + agent.type)
        elif 'sim-end' in type:
            self.info = {}
            self.buffer = '' 
            self.disabled = False
        elif 'bye' in type:
            print('simulation over, exiting')
            sys.exit(0)
        elif 'sim-start' in type:
            sim_info = message.find('simulation')
            if int(sim_info.attrib['id']) != self.sim_id:
                self.sim_id = int(sim_info.attrib['id'])
                self.initialize()
                print('preparing for new simulation')		
            agent.initialize(sim_info)	    
            self.initialized += 1
        else:
            self.percepts.append((agent, message.find('perception')))

    #by smadas - list the roles to check whether they're correctly assigned
    def listRoles(self): 
       for a in self.agents:
          print a.name + " is " + a.type
          

    def start(self):
        self.q = Queue()
        self.agents = [Agent(self.prefix + str(i), self.q, Queue()) for i in range(1,NUM_OF_AGENTS+1)]
        for a in self.agents:
            self.ag_names[a.name] = a
	   ##print ">>>>>>>>>>>>>> " + a.name + a.type

        if self.pickle:
            self.load_backup()
        for a in self.agents:
            a.comm.start()
            time.sleep(0.01)

	#for a in self.agents:
	#   print "333333 " + a.name + a.type

        while True:
            ##for a in self.agents:
	    ##   print "444444 " + a.name + a.type			
            start = time.time()
            self.timeit(self.wait)
            #self.timeit(self.update_entities)
	    ##for a in self.agents:
	    ##   print "55555 " + a.name + a.type
	    #if self.rolesListed is False:
            self.listRoles
	    #   self.rolesListed=True		
            self.timeit(self.handle_percepts)
	    for a in self.agents:
	       print "66666 " + a.name + a.type		
            self.runtime += 1
            #if self.runtime % 10 == 1:
                #sim_id = self.agents[0].message.find('perception').get('id')
                #sim_time = self.agents[0].message.get('timestamp')
                #self.sim_backup = {'total_steps' : self.all[0].total_steps, 'id' : sim_id, 'time' : sim_time, 'runtime' : self.runtime}
                #print self.sim_backup, time.time()

            #if self.pickle:
                #file2 = open(r'sim_backup.pkl', 'rb')
                #sim_backup = pickle.load(file2)
                #file2.close()
                #old_sim = int(sim_backup['id']) / int(sim_backup['total_steps'])
                #new_sim = int(self.sim_backup['id']) / int(self.all[0].total_steps)
                #time_diff = time.time()*1000-int(self.sim_backup['time'])
                #self.runtime = int(sim_backup['runtime'])

                #print old_sim,new_sim,time_diff
                #if old_sim == new_sim and time_diff < 1500000:
                    #self.load_backup()
                    #print "Loaded backup"
            #self.pickle = False
            #if self.runtime % 10 == 1:
                #t = time.time()
                #self.backup()
                #print "backup time: ", time.time()-t


            [x.handle_last_action() for x in self.agents]

            #if self.runtime >= 10 and self.runtime % 10 == 0:
            if self.runtime >= 10:
                self.frontier, self.owned = self.timeit(self.calc_area_control, NUM_OF_AGENTS)
            goals = []

	    
	    
	   	
            for x in self.agents:
                a_goals = self.handle_disabled(x) 
                if a_goals:
                    goals.append(a_goals)
                else:
                    goals.append(self.get_goals(self.vertices[x.info['position']], self.runtime, x))	
	    	
            targets, new_data = self.timeit(self.do_auction, goals)
            [self.do_action(a,t, targets.values()) for a,t in targets.items()]
            print('step#:', self.step, 'since con:', self.runtime, "round time:", time.time() - start)
            pprint.pprint(new_data)
            print()
    def handle_disabled(self, agent):

        ## rep collegue on our own postition hardcoded for 2
        #if agent.type == REP:
            #rep = [x for x in self.vertex_to_agent[agent.info['position']] if agent != x and ag_to_ x.disabled and x.type == REP]
            #if rep:
                #return [Action(self.name + '_repairing_collegue_', REPAIR, arg=rep[0])] 

        if agent.disabled:
            goals = self.n_get_repairer(agent.position, agent)
            if goals:
                if agent.type == REP and len(goals[0].path) > 1:
                    res = self.repair_randomly(agent)
                    if not res is None:
                        return res

                # who is to move
                repairer = [a for a in self.agents if a.name == goals[0].rep][0]
                if agent.type == REP:
                    print(repairer.name, agent.name, len(goals[0].path))

                if (len(goals[0].path) > 1 and not self.rep_in_neighbourhood(agent)) or (len(goals[0].path) == 1 and int(repairer.info['energy']) < goals[0].cost):
#                    print(self.name, 'moving to repairer', goals[0].path[0].id)
                    return [goals[0]]

                ## if both repairers are disabled, let one go all the way
                elif agent.type == REP and agent.disabled and repairer.disabled  and len(goals[0].path) <= 1:
                    if agent.name < repairer.name and len(goals[0].path) == 1:
                        return [goals[0]]
                    if len(goals[0].path) == 1:
                        return [Action(agent.name + '_' + RECHARGE, RECHARGE)]
                    else:
                        return None
                else:
#                    print(self.name, 'repairer in neighbourhood, recharging')
                    return [Action(agent.name + '_' + RECHARGE, RECHARGE)]
            else:
                n = self.get_affordable_neighbour(agent)
                if n is None:
                    print(agent.name, 'no repairers found, nowhere to go, recharging')
                    return [Action(agent.name + '_' + RECHARGE, RECHARGE)]
                else:
                    print(agent.name, 'no repairers found, escaping randomly')
                    return [Action(agent.name + '_' + GOTO, GOTO, n, path = [n], length = agent.position.neighbours[n] )]

        #elif self.type == REP:
        #    return self.repair_randomly()

        return None

    def repair_randomly(self, ag):
            agent = None
            dis = [x.name for x in self.agents if x.disabled]
            sab = [x.name for x in self.agents if x.type == SAB]
            for a in self.vertex_to_agent[ag.info['position']]:
                if a in dis and not a  == ag.name:
                    agent = a
                    if a in sab:
                        break
            if not agent is None:
                return [Action(ag.name + '_repairing_randomly_', REPAIR, arg=agent)]  
            else:
                return None
    
    def rep_in_neighbourhood(self, agent):
        for v in agent.position.neighbours.keys():
            reps_on_pos = [x for x in self.agents if x.type == REP and v.id in self.vertex_to_agent and x.name in self.vertex_to_agent[v.id]]
            if v.id in self.vertex_to_agent and reps_on_pos:
                return True
        return False
    def disabled_in_neighbourhood(self, agent):
        for v in agent.position.neighbours.keys():
            dis_on_pos = [x for x in self.agents if x.disabled and v.id in self.vertex_to_agent and x.name in self.vertex_to_agent[v.id]]
            if v.id in self.vertex_to_agent and dis_on_pos:
                return True
        return False
    
    def rep_on_position(self, position):
        reps_on_pos = [x for x in self.agents if x.type == REP and position.id in self.vertex_to_agent and x.name in self.vertex_to_agent[position.id]]
        if position.id in self.vertex_to_agent and reps_on_pos:
            return True
        return False

    def get_affordable_neighbour(self, agent):
        neigh = None
        best = 100
        for n, value in agent.position.neighbours.items():
            if value < best:
                neigh = n
                best = value

        if best <= int(agent.info['maxEnergyDisabled']) or best == WEIGHT:
            return neigh
        else:
            return None


    def filter_goals(self, goals, type, new_data, agent):

        if type == REP:
            action = REPAIR
        elif type == EXP:
            action = PROBE
        elif type == SAB:
            action = ATTACK
        else:
            return (None, goals)
	
	#by smadas = the number of agents is function of their types
	if type == SAB:
           num_agents = 4
	else:
	   num_agents = 6

        special_goals = [x for x in goals if x.type == action ]
        #if len(special_goals) > NUM_OF_EACH-1: 
	if len(special_goals) > num_agents-1: #by smadas: using this line instead the above one
           goals = special_goals 

        return (None, goals)

    def do_action(self, agent, action, targets):
        if action.type == RECHARGE or agent.should_recharge(action):
            agent.send_action(RECHARGE)
            return

        maxHealth = int(agent.info['maxHealth'])
        strength = int(agent.info['strength'])
	
	if action.type == INSPECT and not action.vertex is None:
	   print "INSPECT NAO EH NONE "
	   action.vertex = None

        if not (action.type == ATTACK and action.vertex is None and action.vertex == agent.position) and self.buy and agent.type == SAB and not agent.disabled and self.money >= PRICE and self.runtime > MAX_PROBE_STEPS and not self.has_sab(agent.position):
            print("Agent %s maxHealth: %s, strength: %s, max_opponent_health: %s, max_opponent_strength: %s"%(agent.name,maxHealth,strength,self.max_opponent_health,self.max_opponent_strength))
            if maxHealth <= INITIAL_MAX_STRENGTH:
                agent.send_action(BUY, HEALTH)
                self.money -=2
                return
            elif strength < self.max_opponent_health:
                agent.send_action(BUY, STRENGTH)
                self.money -= 2
                return

        health = int(agent.info['health'])
	
	
        if not action.vertex is None and action.vertex.id != agent.info['position']:
            if  health < maxHealth and health > 0 and self.rep_on_position(agent.position) and [x for x in targets if agent.name in x.goal]:
                print("OBS OBS repairer in neighbourhood of agent: %s"%(agent.name))
		print "SEND ACTION 1"
                agent.send_action(RECHARGE)
                return
            #agent.send_action(GOTO, 'vertex'+action.path[0].id[1:]) #Maiquel: o parametro deve ser 'vertex99' enquanto o id eh v99
            print "SEND ACTION 2"        
	    agent.send_action(GOTO, action.path[0].id)
            agent.last_goal = action.path[0]
            # print agent.name, type, 'pos', agent.info['position'], 'target', target.vertex.id, 'goto', target.path[0].id
        elif action.type == NOOP:
            if (agent.type == SEN or agent.type == REP) and self.has_sab(agent.position):
                print "SEND ACTION 3"   
                agent.send_action(PARRY)
                return
            elif not agent.position.is_surveyed():
                print "SEND ACTION 4"
                agent.send_action(SURVEY)
                return
            elif agent.type == INS and not agent.should_recharge(Action(None, INSPECT)) and self.get_inspect_sabs(agent.position): 
                print "SEND ACTION 5"
                agent.send_action(INSPECT) 
                print("INSPECTING " )
                return

            agent.send_action(RECHARGE)

        else:
            if action.arg is None and action.type != INSPECT: 
                print "SEND ACTION 6" 
                agent.send_action(action.type)
            else:
                print "SEND ACTION 7"
                agent.send_action(action.type, action.arg)
            # print agent.name, type, agent.info['position']


    def do_auction(self, goals):
        new_data = {}
        targets = {}
        rounds = 0
        while len(new_data) < NUM_OF_AGENTS:
            rounds += 1
	
            for i, a in enumerate(self.agents):
                if len(new_data) >= NUM_OF_AGENTS:
                    break
                ## make sure repairs, attacks and probes are prioritized
                t, local_goals = self.filter_goals(goals[i], a.type, new_data, a)
                if t is not None:
                    targets[a] = t
                    continue
                #Let MAX_BEN be one larger than biggest cost 
                max = 0
                for g in local_goals:
                    if g.cost > max:
                        max = g.cost
                MAX_BEN = max + 1

                has_vertex = False
                for vertex, (name, bid)  in new_data.items(): #@UnusedVariable
                    if name == a.name:
                        has_vertex = True

                if has_vertex:
                    continue		    

                scores = []

                for action in local_goals:
                    if action.goal in new_data:
                        current_bid = new_data[action.goal][1]
                        scores.append((action, MAX_BEN - action.cost - current_bid, current_bid))
                    else:
                        scores.append((action, MAX_BEN - action.cost, 0))
                scores = sorted(scores, key=lambda sc: sc[1], reverse=True)
                current = scores[0][0].goal
                if len(local_goals) == 1:
                    bid = 1
                else:
                    bid = scores[0][2] + scores[0][1] - scores[1][1] + epsilon
                new_data[current] = (a.name, bid)
                targets[a] = scores[0][0]
        if len(new_data) < NUM_OF_AGENTS or rounds > 10:
            print("OBS", rounds)
            #pprint.pprint(new_data)
        return targets, new_data



    def handle_percepts(self):
        for a, p in self.percepts:
            a.info = p.find('self').attrib

        vertices = set()
        entities = set()
        edges = set()
        surveyed = set()
        probed = set()
        inspected = set()

        entities_on_posotion = []
        skip_remaining = False
        num = 0
        for i, (agent, p) in enumerate(self.percepts):
            if i == 0:
                simulation = p.find('simulation')
                self.step = int(simulation.get('step'))
                team_info = p.find('team')
                self.money = int(team_info.get('money'))
                l = team_info.find('achievements')

                if l:
                    for x in l:
                        if x.get('name') == 'surveyed640':
                            self.max_sur = True
            agent.id = p.get('id')
            if skip_remaining:
                continue
            l = p.find('visibleVertices')
            s = set(l)
            if len(s) >= self.total_vertices:
                skip_remaining = True
                print("ownage, ignoring percepts")
            if l:
                vertices = vertices | s 
            l = p.find('visibleEdges')
            if l:
                edges = edges | set(l)
            l = p.find('visibleEntities')
            if l:
                entities = entities | set(l)
            l = p.find('surveyedEdges')
            if l:
                surveyed = surveyed | set(l)

            l = p.find('probedVertices')
            if l:
                probed = probed | set(l)
            l = p.find('inspectedEntities')
            if l:
                inspected = inspected | set(l)
        new_vertices = []
        new_edges = []
        new_entities = []
        new_probed = []
        if not self.team_name:
            for e in entities:
                name, team = e.get('name'), e.get('team')
                if args.prefix in name:
                    self.team_name = team
        for v in vertices:
            id, team = v.get('name'), v.get('team')
            new_vertices.extend(self.handle_vertex_percept(id, team))
        for e in edges:
            v1, v2 = e.get('node1'), e.get('node2')
            new_edges.extend(self.handle_edge_percept(v1, v2))
        for e in surveyed:
            v1, v2, weight = e.get('node1'), e.get('node2'), int(e.get('weight'))
            new_edges.extend(self.handle_edge_percept(v1, v2, weight))
        observed = set()
        for e in entities:
            name, vertex, status, team = e.get('name'), e.get('node'), e.get('status'), e.get('team')
            observed.add(name)            
            new_entities.extend(self.handle_entity_percept(name, vertex))
            # new_entities.append((self.name, self.info['position']))
            # if team != self.team_name and vertex == self.info['position']:
                # entities_on_posotion.append(name)

            if status == 'disabled':
                if team == self.team_name:
                    self.ag_names[name].disabled = True
                else:
                    self.dis_opp.add(name)
            else:
                if team == self.team_name:
                    self.ag_names[name].disabled = False
                elif name in self.dis_opp:
                    self.dis_opp.remove(name)
        for a in self.agents:
            if a.name in self.agent_to_vertex:
                pos = self.agent_to_vertex[a.name]
                del self.agent_to_vertex[a.name]
                self.vertex_to_agent[pos].remove(a.name)
            self.agent_to_vertex[a.name] = a.info['position']
            self.vertex_to_agent[a.info['position']].add(a.name)
            a.position = self.vertices[self.agent_to_vertex[a.name]]
            for other in self.vertex_to_agent[a.info['position']].copy():
                if other != a.name and other not in observed:
                    self.vertex_to_agent[a.info['position']].remove(other)
                    del self.agent_to_vertex[other]


            
        for e in probed:
            name, value = e.get('name'), e.get('value')
            self.handle_probed_vertex(name, value)
            #if name == self.info['position']:
            #    new_probed.append((name, value))
            new_probed.append((name, value))
        for e in inspected:
            name, strength, maxHealth, role = e.get('name'), int(e.get('strength')), int(e.get('maxHealth')), e.get('role')
            if role == SAB and maxHealth > self.max_opponent_health:
                self.max_opponent_health = maxHealth
            if role == SAB and strength > self.max_opponent_strength:
                self.max_opponent_strength = strength
            if not name in self.opponents:
                self.opponents[name] = role


        self.percepts = [] 

        
    def backup(self):
        afile = open(r'sim_backup.pkl','wb')
        pickle.dump(self.sim_backup,afile,-1)
        afile.close()
        
        afile = open(r'vertices.pkl', 'wb')
        vertices = {}
        for vertex in self.vertices.values():
            vertices[vertex.id] = {"value" : vertex.value, "neighbours" : {}}
            for k,v in vertex.neighbours.items():
                vertices[vertex.id]["neighbours"][k.id] = v
        
        pickle.dump(vertices, afile ,-1)
        afile.close()
        
        afile = open(r'known_edges.pkl', 'wb')
        pickle.dump(self.known_edges, afile ,-1)
        afile.close()
        
        afile = open(r'unknown_edges.pkl', 'wb')
        pickle.dump(self.unknown_edges, afile ,-1)
        afile.close()
        
        afile = open(r'opponents.pkl', 'wb')
        pickle.dump(self.opponents, afile ,-1)
        afile.close()
        
        afile = open(r'max_opponent_strength.pkl', 'wb')
        pickle.dump(self.max_opponent_strength, afile ,-1)
        afile.close()
        
        afile = open(r'max_opponent_health.pkl', 'wb')
        pickle.dump(self.max_opponent_health, afile ,-1)
        afile.close()
        
    def load_backup(self):
        
        file2 = open(r'vertices.pkl', 'rb')
        vertices = pickle.load(file2)
        file2.close()
        
        for id in vertices.keys():
            v = Vertex(id)
            self.vertices[id] = v
            v.value = vertices[id]["value"]
        
        for id,vertex in self.vertices.items():
            for neighbour,weight in vertices[id]["neighbours"].items():
                vertex.neighbours[self.vertices[neighbour]]=weight
            
        afile = open(r'known_edges.pkl', 'rb')
        known_edges = pickle.load(afile)
        afile.close()
#        print self.known_edges
        afile = open(r'unknown_edges.pkl', 'rb')
        self.unknown_edges = pickle.load(afile)
        afile.close()
#        print self.unknown_edges
        afile = open(r'opponents.pkl', 'rb')
        self.opponents = pickle.load(afile)
        afile.close()
#        print self.opponents
        afile = open(r'max_opponent_strength.pkl', 'rb')
        self.max_opponent_strength = pickle.load(afile)
        afile.close()
#        print self.max_opponent_health
        afile = open(r'max_opponent_health.pkl', 'rb')
        self.max_opponent_health = pickle.load(afile)
        afile.close()
#        print self.max_opponent_strength
parser = argparse.ArgumentParser()
parser.add_argument('-b', '--buy', help='make the agents shop for upgrades', action='store_true')
parser.add_argument('-d', '--dummy', help='dummy agents', action='store_true')
parser.add_argument('-a', '--attack', help='do attack', action='store_true')
parser.add_argument('-w', '--weak_opp', help='attack EXP and INS in the start of the simulation', action='store_true')
parser.add_argument('-l', '--load_pickle', help='load vertices from pickled data', action='store_true')
parser.add_argument('-v', '--verbosity', type=int, choices=[0,1,2])
parser.add_argument('prefix', help="agent name prefix", choices=['a', 'b', 'Python-DTU'])
args = parser.parse_args()

if args.dummy:
    for i in range(1, NUM_OF_AGENTS+1):
        Communicator(args.prefix+str(i), None, None, True).start()
        time.sleep(0.01)
    print('running dummies')
    while True:
        time.sleep(2)
r = Runner()
r.start()
print('Stopped')
