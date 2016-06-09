#!/usr/bin/python

import threading
import socket
import struct
from time import sleep
import sys

OPTITRACK_ADDRESS 	= "239.255.42.99"
OPTITRACK_PORT 		= 1511

class Optitrack_Thread ( threading.Thread ):
	def __init__(self, nom = ''):
		threading.Thread.__init__(self)
		self.Terminated = False
        
	def run ( self ):
		sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP) 
		sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1) 
		sock.bind(('', OPTITRACK_PORT)) 
		mreq = struct.pack("=4sl", socket.inet_aton(OPTITRACK_ADDRESS), socket.INADDR_ANY) 
		sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq) 

		while not self.Terminated:
			data = sock.recv(1024) 
			v = struct.unpack('hhiiiii',data[0:24])

			#markers
			for i in range(int(v[6])):
				debut = 24+int(v[5])*4*7 + i*3*4
				vals = struct.unpack("fff",data[debut:debut+3*4])
				print i,"\t",vals[0]*1000,"\t",-vals[2]*1000,"\t",vals[1]*1000
				sys.stdout.flush()
			
	def stop( self ):
		print "stopping Optitrack Thread" 
		self.Terminated = True
		print "Stopped"



Opti_T = Optitrack_Thread() 
Opti_T.start()
#sleep(5)
#Opti_T.stop()
