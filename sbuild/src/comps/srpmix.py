#!/usr/bin/python

import sys

hash = {}

for line in sys.stdin.readlines():
    if len(line) > 0:
        if not hash.has_key(line[0]): hash[line[0]] = []
        hash[line[0]].append(line.strip())

for h in hash.keys():
    print " ".join(hash[h])

