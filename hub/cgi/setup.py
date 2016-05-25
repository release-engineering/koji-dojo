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
import subprocess
import tempfile
from datetime import datetime

BASE_PATH = '/var/www/html/setup-scripts'

host=os.environ.get('HTTP_HOST')
port=os.environ.get('SERVER_PORT')
if port == '80':
  port = ''
else:
  port = ':' + port

docroot=os.environ.get('DOCUMENT_ROOT')

def script_url(path):
  scriptname = path[len(docroot):]
  return 'http://%s%s%s' % (host, port, scriptname)

script=None
log=None

method = os.environ.get('REQUEST_METHOD').lower()
# sanity-check method
if method is None or method not in ('post'):
  status='error'

else:
  if not os.path.exists(BASE_PATH):
    os.makedirs(BASE_PATH)

  script = tempfile.NamedTemporaryFile(prefix="setup-", suffix='.sh', delete=False, dir=BASE_PATH)
  status = 'ok'

  content=sys.stdin.read()
  sys.stderr.write("Creating setup script from:\n\n%s\n" % (content))

  script.write(content)
  script.write('\n')
  script.close();

  output = ''

  sys.stderr.write("Executing temp script: %s" % script.name)
  process = subprocess.Popen(['/usr/bin/sudo', '/bin/sh', script.name], stdout=subprocess.PIPE, shell=False)
  output, _err = process.communicate()

  retcode = process.poll()
  if retcode:
    status = "Script failed with exit value: {0}\n\n{1}".format(retcode, output)

  sys.stderr.write("Script exited with value: %s" % retcode)

  log = os.path.join(BASE_PATH, 'command.log')
  entry="# Executed at: {timestamp}\n{script}\n\n".format(timestamp=str(datetime.now()), script=script_url(script.name))
  with open(log, "a") as logfile:
    logfile.write(entry)


if script is not None:
  scriptUrl = script_url(script.name)
else:
  scriptUrl = "None"

if log is not None:
  logUrl = script_url(log)
else:
  logUrl = "None"

if status == 'error':
  print """Status: 400
Content-Type: text/plain

Only POST requests are supported.
"""
elif status == 'ok':
  print """Status: 200
Content-Type: text/plain
Script-Location: {script}
Script-Log: {log}

{output}
""".format(output=output, script=scriptUrl, log=logUrl)
else:
  print """Status: 500
Content-Type: text/plain
Script-Location: {script}
Script-Log: {log}

{status}.
""".format(status=status, script=scriptUrl, log=logUrl)

