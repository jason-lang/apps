import os
import time
import random
import threading
from global_vars import * #@UnusedWildImport
from algorithms import Algorithms

class Timer(threading.Thread):

    def __init__(self, seconds, agent):
        self.sleep_time = seconds
        threading.Thread.__init__(self)
        self.agent = agent
        self.stop = False
        
    def run(self):
        while True and not self.stop:
            time.sleep(self.sleep_time)
            self.agent.draw(self.agent.get_info())

class Edge():
    def __init__(self, v1, v2):
        if v1 < v2:
            self.v1 = v1
            self.v2 = v2
        else:
            self.v1 = v2
            self.v2 = v1
        self.hash = hash(self.v1 + self.v2)
        
    def __cmp__(self, other):
        return cmp(self.hash, other.hash)
    def __eq__(self, other):
        return self.hash == other.hash   
    def __ne__(self, other):
        return self.hash != other.hash            
    def __hash__(self):
        return self.hash

        
class Vertex():
    def __init__(self, id, color='black'):
        self.in_paths = False
        self.id = id
        #self.hash = int(id[6:])
	self.hash = int(id[1:])
        self.color = color
        self.value = 0
        self._surveyed = False
        self.neighbours = {}
        self.shortest_path = {}
        self.intermediate = {}
            
    def is_surveyed(self):
        if len(self.neighbours) == 1:
            return False
        #unknown_edge = filter(lambda x: x == WEIGHT, self.neighbours.values())
        unknown_edge = [x for x in self.neighbours.values() if x == WEIGHT]

        if not unknown_edge:
            return True
        else:
            return False
    
    def random_neighbour(self):
        c = len(self.neighbours)
        if c == 0:
            return None
        else:
            ran = random.randint(0, c - 1)
            n = list(self.neighbours.iterkeys())
            return n[ran]

    def __cmp__(self, other):
        return cmp(self.hash, other.hash)
    def __eq__(self, other):
        return self.hash == other.hash   
    def __ne__(self, other):
        return self.hash != other.hash            
    def __hash__(self):
        return self.hash
    def __str__(self):
        return self.id
    def __repr__(self):
        return self.id
    
class Graph(Algorithms):
    
        
    def handle_edge_percept(self, v1, v2, weight=WEIGHT):
        n1 = v1
        n2 = v2
        e = Edge(v1, v2)
        if e in self.known_edges:
            return []
        if weight == WEIGHT and e in self.unknown_edges:
            return []
    
        if weight != WEIGHT:
            self.known_edges.add(e)
        else:
            self.unknown_edges.add(e)
    
        if v1 in self.vertices:
            v1 = self.vertices[v1]
        else:
            v1 = Vertex(v1, 'black')
            self.vertices[v1.id] = v1
        if v2 in self.vertices:
            v2 = self.vertices[v2]
        else:
            v2 = Vertex(v2, 'black') 
            self.vertices[v2.id] = v2

    
        if not v2 in v1.neighbours or (v1.neighbours[v2] == WEIGHT):
            v1.neighbours[v2] = weight
            v2.neighbours[v1] = weight
                    

        return [(n1, n2, weight)]
    
    def update_entities(self):
            
        for agent in self.agents:
            if agent in self.agent_to_vertex:
                pos = self.agent_to_vertex[agent]
                for a in self.vertex_to_agent[pos]:
                   del self.agent_to_vertex[a]
                    
            #    self.vertex_to_agent[pos].clear()
        #self.vertex_to_agent = {}
        #self.agent_to_vertex = {}
                
    def handle_entity_percept(self, agent, vertex):
        
        if agent in self.agent_to_vertex:
            prev_vertex = self.agent_to_vertex[agent]
            if prev_vertex == vertex:
                return []
            self.vertex_to_agent[prev_vertex].remove(agent)
        self.agent_to_vertex[agent] = vertex
        if vertex in self.vertex_to_agent:
            self.vertex_to_agent[vertex].add(agent)
        else:
            self.vertex_to_agent[vertex] = set([agent])


        return [(agent, vertex)]
            
    def get_by_agent(self, key):
        return self.agent_to_vertex[key]

    def get_by_vertex(self, key):
        try:
            return self.vertex_to_agent[key]
        except:
            return str([])
            
                    
    def handle_probed_vertex(self, id, val):
        self.vertices[id].value = int(val)
        
        
    def handle_vertex_percept(self, id, team): 
        new = []  
                
        if team == 'A':
            color = 'blue'
        elif team == 'B':
            color = 'green'
        elif team == 'none':
            color = 'black'
        else:
            color = team
    
        if id in self.vertices:
            v = self.vertices[id]
            if v.color != color:
                v.color = color
                new.append((id, team))
        else:
            v = Vertex(id, color)
            v.team = team
            self.vertices[id] = v
            new.append((id, team))
        
        return new
        
    def get_dot(self):
        a = 'graph graphname { node [    shape = rectangle ] \n'
        for vertex in self.vertices.itervalues():
            a += '{0} [color="{1}", label="{0} {2} {3}"] \n'.format(vertex.id[5:], vertex.color, str(self.get_by_vertex(vertex.id))[5:-2], vertex.value)
            
        for vertex in self.vertices.itervalues():
            for (neighbour, weight) in vertex.neighbours.iteritems():
                if vertex.id > neighbour.id:
                    a += '{0} -- {1} [label="{2}"] \n'.format(vertex.id[5:], neighbour.id[5:], weight)
        a += ' overlap=false }'
        
        return a
        
    def draw(self, info):
        lines = []
        # if agent.name == 'a1':
        html = open('localview.html', 'r')
        for line in html:
            if 'info' in line:
                line = 'info: ' + info
                line += '\n'
            lines.append(line)
              
        html.close()
        html = open('localview.html', 'w')
        html.writelines(lines)
        html.close()

        f = open('graph.dot', 'w')
        f.write(self.get_dot())
        f.close()
        os.system('neato  graph.dot -Tpng -o graph.png')


        

