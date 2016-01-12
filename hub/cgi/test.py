#!/usr/bin/env python
# -*- coding: UTF-8 -*-# enable debugging
import os
import cgi
import cgitb

cgitb.enable()

print "Content-Type: text/html;charset=utf-8"
print
print """
<html>
  <head>
    <title>Request Debug</title>
    <style>
      dt{font-weight: bold;}
    </style>
  </head>
  <body>
    <h1>Parameters</h1>
"""
params = cgi.FieldStorage()
for key in sorted(params.keys()):
	print """
      <dt>%s</dt>
      <dd>%s</dd>
""" % (key, params[key].value)
print """
    </dl>"""
print """
    <h1>Variables</h1>
    <dl>"""
for key in sorted(os.environ.iterkeys()):
	print """
      <dt>%s</dt>
      <dd>%s</dd>
""" % (key, os.environ.get(key))
print """
    </dl>
  </body>
</html>"""

