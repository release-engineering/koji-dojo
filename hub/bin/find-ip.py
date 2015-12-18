#!/usr/bin/env python2

import sys
import socket
import fcntl
import struct

if len(sys.argv) > 1:
	ifc = sys.argv[1]
	if ifc.endswith(':'):
		ifc = ifc[0:-1]
else:
	ifc='eth0'

try:
	s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	ip = socket.inet_ntoa(fcntl.ioctl(
	    s.fileno(),
	    0x8915,  # SIOCGIFADDR
	    struct.pack('256s', ifc[:15])
	)[20:24])
except:
	print "Cannot find IP address for:", ifc
	sys.exit(127)

print str(ip)
