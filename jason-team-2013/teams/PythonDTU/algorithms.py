 
from global_vars import * #@UnusedWildImport
import copy #@Reimport
from heapq import heappush, heappop #@Reimport
import random
import time



class Action():
    def __init__(self, goal, type, vertex=None, cost=0, path=[], arg='', length = 0):
        self.goal = goal
        self.type = type
        self.vertex = vertex
        self.cost = cost
        self.path = path
        self.arg = arg
        self.length = length

    def __gt__(self, other):
        return self.vertex.id >=  other.vertex.id
    def __lt__(self, other):
        return self.vertex.id <  other.vertex.id
    def __eq__(self, other):
        return self.vertex == other.vertex
    def __cmp__(self, other):
        return cmp(self.vertex, other.vertex)
    def __hash__ (self):
        return self.vertex.hash
    def __repr__(self):
        return repr(str(self.goal) + ' ' +  str(self.cost))

def get_opps(team):
    if team == 'A':
        return 'B'
    else:
        return 'A'
class Algorithms():
    #n: antallet af agenter
    
    def calc_area_control(self,n):

        #Find root
        root = None
        maxValue = 0

        for v in self.vertices.values():
            neighbourhood = set([v])
            neig = set(v.neighbours.keys())
            neighbourhood = neighbourhood | neig
            for w in neig:
                
                neig2 = set(w.neighbours.keys())
                neighbourhood = neighbourhood | neig2

            value = 0
            for w in neighbourhood:
                value += w.value
                

            if root is None or value > maxValue:
                root = v
                maxValue = value

        print('root is: ' + str(root))
        #Do greedy algorithm

        chosen = set([root])
        doubles = set()
        for i in range(n-1):
            best = None
            bestValue = 0

            owned = self.calcOwned(chosen)

        

            for v in self.vertices.values():
                if v in chosen:
                    continue
                opps = []
                #if v.id in self.vertex_to_agent:
                    #opps = [x for x in self.vertex_to_agent[v.id] if x not in self.ag_names and not x in self.dis_opp]
                #if v.team == get_opps(self.team_name) and not opps:
                        ## count double if opponent owns without having an agent in w
                    #doubles.add(v.id)
                    #value = 2*v.value
                #else:
                    #value = v.value
                
                value = v.value
                
                # only add neighbours if no opps on v
                if not opps:
                    for w in v.neighbours.keys():
                        if w in owned:
                            continue
                        else:
                            for z in w.neighbours.keys():
                                if z in chosen:
                                    value += w.value
                                    break

                if best is None or value > bestValue:
                    best = v
                    bestValue = value

            chosen = chosen | set([best])

        print(doubles)
        return chosen, self.calcOwned(chosen)

    def calcOwned(self,chosen):
        owned = set(chosen)

        for v in chosen:
            for w in chosen:
                if v == w:
                    continue

                owned = owned | (set(v.neighbours.keys()) & set(w.neighbours.keys()))

        return owned

    def calcValue(self,chosen):
        owned = self.calcOwned(chosen)
        value = 0
        for v in owned:
            value += v.value

        return value


    def bfs(self, prefix, type, start, function, count, agent):
        explored = set()
        frontier = PriorityQueue()
        goals = []
        frontier.push(Action(prefix+start.id, type, start))
        counter = 0
        while len(frontier) > 0:
            counter += 1
            current = frontier.pop()
            while len(frontier) > 0 and current.vertex in explored:
                current = frontier.pop()
                if len(frontier) == 0:
                    return goals

            explored.add(current.vertex)
            function(current, goals, agent)
            if counter > BFS_ROUNDS:
                print("BFS MAX")
                return goals
            if len(goals) == count:
                return goals #sorted(goals, lambda x,y: cmp(x.cost, y.cost))

            neighbours = current.vertex.neighbours.items()
            for (v,weight) in neighbours:
                if v in explored:
                    continue

                path = copy.copy(current.path)
                path.append(v)
    #                    frontier.push(Action(prefix+v.id, type, v, cost = current.cost + weight, length = current.cost + weight, path = path))
                if weight == WEIGHT:
                    l_weight = MAX_EDGE_WEIGHT
                else:
                    l_weight = weight
                frontier.push(Action(prefix+v.id, type, v, cost = current.cost + weight + agent.recharge_rate(), length = current.length + l_weight, path = path))

        return goals #sorted(goals, lambda x,y: cmp(x.cost, y.cost))


    def find_init(self):
        edges = 100
        value = 0
        cur = None
        for v in self.vertices.values():
            if v.value < value:
                continue
            if v.value > value:
                cur = v
                edges = len(v.neighbours)
                value = cur.value
            if v.value == value:
                n = len(v.neighbours)
                if n < edges or (n == edges and v.id < cur.id):
                    cur = v
                    edges = n
                    value = cur.value

        return cur 


    def get_goals(self, start, runtime, agent):
        goals = []
        # repairers and attackers keep up the good work
        if agent.type == INS:
            if len(self.opponents) < NUM_OF_AGENTS:
                goals = self.bfs('inspect_', INSPECT, start, self.get_inspect, NUM_OF_EACH, agent)
        elif agent.type == SAB: 
            if self.do_attack:
                if runtime > MAX_SURVEY_STEPS: 
                    goals = self.bfs('attack_owned_', ATTACK, start, self.get_opponent_in_owned, NUM_OF_EACH, agent)
                    for g in goals:
                        g.cost = g.cost - 100 
                    if len(goals) < NUM_OF_EACH:
                        goals.extend(self.bfs('attack_', ATTACK, start, self.get_opponent, NUM_OF_EACH - len(goals), agent))
                else:
                    goals = self.bfs('attack_', ATTACK, start, self.get_opponent, NUM_OF_EACH, agent) 
        elif agent.type == SEN and not self.max_sur and runtime < MAX_PROBE_STEPS:
            goals = self.bfs('survey_', SURVEY, start, self.is_unsurveyed, NUM_OF_AGENTS, agent)
        elif agent.type == REP:
            num_of_dis = len([x for x in self.agents if x.disabled])
            goals = self.bfs('repair_', REPAIR, start, self.is_broken, num_of_dis, agent)
            if len(goals) < NUM_OF_EACH:
                e_goals = self.bfs('refresh_', REPAIR, start, self.get_hit, NUM_OF_EACH - len(goals), agent)
                goals.extend(e_goals)
        elif agent.type == EXP:
            goals = self.bfs('probe_owned_', PROBE, start, self.unprobed_in_owned, NUM_OF_EACH, agent) 
            if len(goals) < NUM_OF_EACH:
                if runtime < MAX_PROBE_STEPS+EXTRA_PROBE_STEPS:
                    goals.extend(self.bfs('probe_', PROBE, start, self.is_unprobed, NUM_OF_EACH - len(goals), agent))

        if len(goals) < NUM_OF_EACH and not self.max_sur and runtime < MAX_SURVEY_STEPS and agent.type != SEN:
            extra_goals = self.bfs('survey_', SURVEY, start, self.is_unsurveyed, NUM_OF_AGENTS - len(goals), agent)
            goals.extend(extra_goals)
        elif len(goals) < NUM_OF_EACH:
            goals.extend(self.bfs('expand_', NOOP, start, self.get_frontier, len(self.frontier), agent) )

        while len(goals) < NUM_OF_AGENTS:
            goals.append(Action(agent.name + '_ignore', NOOP, cost = NOOP_COST))

        return goals

    def get_frontier(self, v, goals, agent):
        if v.vertex in self.frontier:
            goals.append(v)
  
    def is_unprobed(self, v, goals, agent):
        if v.vertex.value == 0:
            goals.append(v)
    def unprobed_in_owned(self, v, goals, agent):
        if v.vertex.value == 0 and v.vertex in self.owned:
            goals.append(v)
    def is_unsurveyed(self, v, goals, agent):
        if not v.vertex.is_surveyed():
            goals.append(v)

    def n_get_repairer(self, start, agent):

        def har_repairer(v, goals, agent):
            if v.vertex.id in self.vertex_to_agent:
                vert_to_ag = self.vertex_to_agent[v.vertex.id].copy()
                ## only go to disabled repairer if you are a repairer and you are disabled
                dis = [x.name for x in self.agents if x.disabled]
                reps = [x.name for x in self.agents if x.type == REP]
                match = [x for x in vert_to_ag if x in reps and x != agent.name and (x not in dis or (agent.type == REP and agent.disabled))]
                if match:
                    v.rep = match[0]
                    goals.append(v)

        return self.bfs(agent.name + '_find_repairer_', GOTO, start, har_repairer, 1, agent)
  	
    def get_inspect_sabs(self, vertex):
        match = self.has_opponent(vertex)
        ## filter for not prev inspected
        #match = filter(lambda x: not x in self.opponents.keys() or (self.opponents[x] == SAB or self.opponents[x] == REP), match)
        match = [x for x in match if not x in self.opponents.keys() or (self.opponents[x] == SAB or self.opponents[x] == REP)]
            ## it's just as good if oppnonts are at neighbour vertices
        if not match:
            for n in vertex.neighbours:
                match = self.has_opponent(n)
                #match = filter(lambda x: not x in self.opponents.keys() or (self.opponents[x] == SAB or self.opponents[x] == REP), match)
                match = [x for x in match if not x in self.opponents.keys() or (self.opponents[x] == SAB or self.opponents[x] == REP)]
                if match:
                    break

        return match

    def get_inspect(self, v, goals, agent):
        match = self.has_opponent(v.vertex)
        ## filter for not prev inspected
        match = [x for x in match if x not in self.opponents.keys()]
            ## it's just as good if oppnonts are at neighbour vertices
        if not match:
            for n in v.vertex.neighbours:
                match = self.has_opponent(n)
                match = [x for x in match if x not in self.opponents.keys()]
                if match:
                    break
        if match:
            goals.append(v)

    def get_opponent_in_owned(self, v, goals, agent):
        if v.vertex not in self.owned:
            return
        match = self.has_opponent(v.vertex)      
        res = []
        for agent in match:
            if not agent in self.dis_opp:
                res.append(agent)              
        if res:
            op = res[0]
            for a in res:
                if a in self.opponents:
                    if self.opponents[a] == 'Saboteur':
                        op = a
                        break
                    if self.opponents[a] == 'Repairer':
                        op = a

            v.arg = op
            v.goal = op + '_' + v.goal
            goals.append(v)             

    def get_opponent(self, v, goals, agent):
        match = self.has_opponent(v.vertex)      
        res = []
        for a in match:
            if not a in self.dis_opp:
                res.append(a)
        if res:
            op = res[0]
            for a in res:
                if a in self.opponents:
                    if self.opponents[a] == 'Saboteur':
                        op = a
                        break
                    if self.runtime < MAX_ATTACK_WEAK_STEPS and self.weak_opp:
                        if not self.has_sab(agent.position) and (self.opponents[a] == 'Explorer' or self.opponents[a] == 'Inspector'):
                            op = a
                            break
                    else:
                        if self.opponents[a] == 'Repairer':
                            op = a
                    
            v.arg = op
            v.goal = op + '_' + v.goal
            goals.append(v) 

    def get_hit(self, v, goals, agent):
        if v.vertex.id in self.vertex_to_agent:
            vert_to_ag = self.vertex_to_agent[v.vertex.id].copy()
            ag_names = [x.name for x in self.agents]
            hit = [x.name for x in self.agents if int(x.info['health']) < int(x.info['maxHealth'])]
            match = [ x for x in vert_to_ag if x != agent.name and x in ag_names and x in hit]
            if match:
                v.arg = match[0]
                v.goal = match[0] + '_' +  v.goal
                goals.append(v)

    def is_broken(self, v, goals, agent):
        if v.vertex.id in self.vertex_to_agent:
            vert_to_ag = self.vertex_to_agent[v.vertex.id].copy()
            dis = [x.name for x in self.agents if x.disabled]
            match = [x for x in vert_to_ag  if x != agent.name and x in dis]
            if match:
                reps_in_match = [x.name for x in self.agents if x.type == REP and x.name in match]
                if reps_in_match:
                    v.cost = 0
                    v.arg = reps_in_match[0]
                    v.goal = reps_in_match[0] + '_collegue_' +  v.goal
                else:
                    v.arg = match[0]
                    v.goal = match[0] + '_' +  v.goal

                goals.append(v)


class PriorityQueue():

    def __init__(self):
        self.list = []
    def push(self, val):
        heappush(self.list, (val.cost, val))
        
    def pp(self, val):
        return heappushpop(self.list, (val.cost, val))[1]
        
    def pop(self):   
        element = heappop(self.list)
        return element[1]
        
    def __len__(self):
        return len(self.list)
    def __repr__(self):
        return repr(self.list)
        
    def __iter__(self):
        for n in self.list:
            yield n
