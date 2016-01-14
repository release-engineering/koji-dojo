#!/usr/bin/env python
# -*- coding: UTF-8 -*-# enable debugging
import os
import cgi
import cgitb

cgitb.enable()

print "Content-Type: text/plain;charset=utf-8"
print
print """
[parameters]
"""
params = cgi.FieldStorage()
for key in sorted(params.keys()):
  val = params[key]
  if isinstance(val, list) is True:
    for v in val:
      print "%s=%s\n" % (key, v.value)
  else:
  	print "%s=%s\n" % (key, params[key].value)

print """

[variables]
"""
for key in sorted(os.environ.iterkeys()):
	print "%s=%s\n" % (key, os.environ.get(key))

