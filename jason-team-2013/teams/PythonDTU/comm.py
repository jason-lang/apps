import time
import xml.etree.cElementTree as etree
import socket
import sys
import select
from global_vars import *
import multiprocessing 



end = b'\0'

class Communicator(multiprocessing.Process):

    def __init__(self, name, w_q, r_q, dummy =False):
        multiprocessing.Process.__init__(self)
        self.auth = etree.fromstring('''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <message type="auth-request"><authentication password="test" username="test"/></message>''')

        self.daemon = True
        self.name = name
        self.w_q = w_q
        self.r_q = r_q
        self.buffer = b'' 
        self.dummy = dummy
        self.running = True

    def run(self):

        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, 12300))
        s.settimeout(0.01)
        self.s = s
        auth_ele = self.auth.find('authentication')
        auth_ele.attrib['username'] = self.name
        auth_ele.attrib['password'] = PASSWORD 
        self.s.send(etree.tostring(self.auth) + end)
        self.reading = True
        while True:
            self.handle_read()

    def handle_read(self):
        try:
            self.buffer += self.s.recv(8192)
        except Exception as e:
            pass
        c = self.buffer.find(end) 
        if c == -1:
            return
        else:
            string = self.buffer[:c].decode()
            #if not ('sim-start' in string or 'auth-response' in string):
                #self.reading = False
            if not self.dummy:
                self.w_q.put((self.name, string))
            if 'request-action' in string:
                message = ''
                if self.dummy:
                    cut = string[string.find('id="')+4:]
                    num = cut[:cut.find('"')]
                    message = bytes('''<?xml version="1.0" encoding="UTF-8"?>
                    <message type="action"><action id="{}" type="skip" />
                    </message>\0'''.format(num), 'UTF-8')
                else:
                    message = self.r_q.get()
                self.s.send(message)
            self.buffer = self.buffer[c+1:]

class Agent:

    def __init__(self, name, w_q, r_q, dummy =False):
        self.auth = etree.fromstring('''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <message type="auth-request"><authentication password="test" username="test"/></message>''')

        self.action = etree.fromstring('''<?xml version="1.0" encoding="UTF-8"?><message type="action"><action id="" type="goto" /></message>''')
        self.daemon = True
        self.name = name
        self.r_q = r_q
        self.info = {}
        self.id = ''
        self.disabled = False
        self.position = None
        self.recharge_r = 0
        self.dummy = dummy
        self.running = True
        self.comm = Communicator(name, w_q, r_q, dummy)
	self.type = ''

    def initialize(self, info):
        self.info = info
        self.type = self.info.attrib['role']
        self.total_steps = self.info.attrib['steps']
        self.print_info()
	#print "7xy7xy7xy7xy7xy7xy7x7" + self.type

    def print_info(self):
        print(self.name,  'Simulation started, total edges:', self.info.attrib['edges'], 'total vertices:', self.info.attrib['vertices'], 'steps:', self.info.attrib['steps'])

    def handle_last_action(self):
        if self.info['lastActionResult'] != 'successful':
            if 'wrong' in self.info['lastActionResult']:
                print('OBS OBS', self.name, self.info['lastActionResult'], ' : ', self.info['lastAction'])
            if 'away' in self.info['lastActionResult']:
                f =open(self.name[0]+"away.log", "a")
                f.write("".join(['OBS OBS', self.name, self.info['lastActionResult'], ' : ', self.info['lastAction']]) + '\n')
                f.close()	

                print('OBS OBS', self.name, self.info['lastActionResult'], ' : ', self.info['lastAction'])
            else:
                print(self.name, self.info['lastActionResult'], ' -:- ', self.info['lastAction'])
        else:
	   print('OBS FINE', self.name, self.info['lastActionResult'], ' : ', self.info['lastAction']) 

    def recharge_rate(self):
        if self.recharge_r == 0:
            self.recharge_r = int(self.info['maxEnergy'])/2
        return self.recharge_r

    def should_recharge(self, action):
        total_cost = action.length + COSTS[action.type]
    # we can go all way without recharging
        if total_cost < int(self.info['energy']):
            return False

        # we can't make a single step without recharging
        if action.path and self.position.neighbours[action.path[0]] > int(self.info['energy']):
            return True
        if action.path and self.position.neighbours[action.path[0]] == WEIGHT and int(self.info['energy']) < MAX_EDGE_WEIGHT:
            return True
        # we are below recharge rate and may just as well recharge
        a = not self.disabled and int(self.info['energy']) <= self.recharge_rate()
        # recarge rate is 30% when disabled
        b = self.disabled and int(self.info['energy']) <= (1-RECHARGE_DIS)*int(self.info['maxEnergyDisabled'])

        if a or b:
            return True
        else:
            return False

    def send_action(self, type, param=None):
        action_ele = self.action.find('action')
        action_ele.attrib['id'] = self.id
        action_ele.attrib['type'] = type
	if type == INSPECT:
	   param = None  
	   if param is None:
   	      print "O PARAMETRO AGORA EH NONE"
	   print "O TIPO EH INSPECT x " 
        if param is not None:               
            action_ele.set('param', param)

	x = self.action.find('action')
	y = x.getiterator('action')
	for i in y:
   	   if i.attrib['type']=='inspect':
              i.attrib['param'] = ''
        
	
        self.r_q.put(etree.tostring(self.action) + end)
	print "SEND: " + etree.tostring(self.action) + end
