#!/usr/bin/python

import cgi
import re
import os.path
import os
import sys
import subprocess



SOCKET_DIR = "/home/masatake/tmp"
OUTPUT_DIR = "/home/masatake/tmp"



form = cgi.FieldStorage()
target = form.getvalue('target')


if not target:
    print "Content-type: text/html"
    print
    print "error: no target"  
    sys.exit

pat = re.compile(r'http://(www.)?srpmix.org/sources/sources/(.+)')
mat   = pat.match(target)
if not mat:
    print "Content-type: text/html"
    print 
    print "error: wrong target\n"
    sys.exit
else:
    target = mat.group(2)

target = '/home/masatake/www.srpmix.org/sources/sources/' + target
target = os.path.normpath(target)

def invoke_emacs (target):
    stat = subprocess.call(["/home/masatake/tools/bin/emacsclient",
                            "--socket-name=" + SOCKET_DIR + "/" + ".flserver",
                            "--eval", "(flserver-htmlize " +
                            "\"" + target + "\" \"" + OUTPUT_DIR + "\")"])
    if stat != 0:
        print "Content-type: text/html"
        print
        if os.path.isdir(target):
            os.system  ("ls " + target)
        else:
            os.system  ("cat " + target)
    else:
        print "Content-type: text/html"
        print
        result = OUTPUT_DIR + "/" + os.path.basename(target) + ".html"
        sys.stdout.flush()
        result2 = result + "2" 
        os.system("cat " + result + "| sed -e s+/home/masatake/www.srpmix.org/g++ | sed -e s/dr/DR/ > " + result2)
        os.system("cat " + result2)
        #os.remove(result)
    
invoke_emacs(target)
