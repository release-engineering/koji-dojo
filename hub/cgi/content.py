#!/usr/bin/python
#
# Copyright (C) 2015 John Casey (jdcasey@commonjava.org)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import os
import sys

BASE_PATH = '/var/www/html'

method = os.environ.get('REQUEST_METHOD').lower()
# sanity-check method
if method is None or method not in ('put','delete'):
  status='error'

else:
  path = os.environ.get('PATH_INFO').strip("/")
  filepath = os.path.join(BASE_PATH, path)

  sys.stderr.write("Path-Info: '%s'\nActual file: '%s'\nBase path: '%s'\n" % (path, filepath, BASE_PATH))

  if method == 'put':
    status = 'updated'

    filedir = os.path.dirname(filepath)
    if not os.path.exists(filedir):
      os.makedirs(filedir)

    if not os.path.exists(filepath):
      status='new'

    content=sys.stdin.read()
    with open(filepath, 'w') as f:
      f.write(content)
  elif method == 'delete':
    if not os.path.exists(filepath):
      status='missing'
    else:
      os.remove(filepath)
      status='deleted'

if status == 'error':
  print """Status: 400
Content-Type: text/plain

Only PUT and DELETE requests are supported.
"""
elif status == 'missing':
  print """Status: 404
Content-Type: text/plain

Path not found: /{path}
""".format(path=path)
elif status == 'new':
  print """Status: 201
Content-Type: text/plain
Location: /{path}

Created /{path}
""".format(path=path)
elif status == 'deleted':
  print """Status: 204
Content-Type: text/plain

Deleted /{path}
""".format(path=path)
elif status == 'updated':
  print """Status: 200
Content-Type: text/plain

Modified /{path}
""".format(path=path)
else:
  print """Status: 500
Content-Type: text/plain

Unknown status: {status}.
""".format(status=status)

