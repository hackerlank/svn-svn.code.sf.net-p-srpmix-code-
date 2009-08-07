#!/usr/bin/env python

import sys
import xml.dom.minidom

def merge_comps( comp1, comp2 ):
    groups = {}
    for group in comp1.getElementsByTagName('group'):
        id = group.getElementsByTagName('id')[0].firstChild.nodeValue
        groups[id] = group

    for group in comp2.getElementsByTagName('group'):
        id = group.getElementsByTagName('id')[0].firstChild.nodeValue
        if groups.has_key(id):
            list = groups[id].getElementsByTagName('packagelist')[0]
            for pkg in group.getElementsByTagName('packagereq'):
                list.appendChild( pkg )
        else:
            comps = comp1.getElementsByTagName('comps')[0]
            group.parentNode.removeChild( group )
            comps.appendChild( group )

    categories = {}
    for category in comp1.getElementsByTagName('category'):
        id = category.getElementsByTagName('id')[0].firstChild.nodeValue
        categories[id] = category

    for category in comp2.getElementsByTagName('category'):
        id = category.getElementsByTagName('id')[0].firstChild.nodeValue
        if categories.has_key(id):
            list = categories[id].getElementsByTagName('grouplist')[0]
            for pkg in category.getElementsByTagName('groupid'):
                list.appendChild( pkg )
        else:
            comps = comp1.getElementsByTagName('comps')[0]
            category.parentNode.removeChild( category )
            comps.appendChild( category )

comps1 = xml.dom.minidom.parse(sys.argv[1])
if len(sys.argv) > 2:
    for i in sys.argv[2:]:
        print >>sys.stderr, "merge %s" % i
        comps = xml.dom.minidom.parse(i)
        merge_comps( comps1, comps )

print comps1.toxml()

