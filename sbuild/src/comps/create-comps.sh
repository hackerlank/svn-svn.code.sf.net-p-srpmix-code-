#!/bin/sh
# find . -type f |grep -v dir-pkg  |xargs -n 1 basename | sed -e 's/\(.*\)-srpmix.*/\1/' -e :loop -e 's/\(.\+\)-[0-9].*/\1/' -e 't loop' -e p | less

FILE=$1
DIST=$(basename $FILE .es)
NAME=$2
DESCRIPTION=$3

echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<!DOCTYPE comps PUBLIC "-//Red Hat, Inc.//DTD Comps info//EN" "comps.dtd">'
echo '<comps>'

echo ' <group>'
echo "  <id>srpmix-$DIST</id>"
echo "  <name>$NAME</name>"
echo "  <description>$DESCRIPTION</description>"
echo "  <default>true</default>"
echo "  <uservisible>true</uservisible>"
echo '  <packagelist>'
echo "   <packagereq type=\"mandatory\">srpmix-weakview-dist-$DIST</packagereq>"
echo "   <packagereq type=\"mandatory\">srpmix-weakview-packages-$DIST</packagereq>"
echo "   <packagereq type=\"mandatory\">srpmix-weakview-alias-$DIST</packagereq>"

cat $1 | while read line
do
  name=$(echo $line | sed 's/.*:wrapped-name "\(.*\)".*/\1/')
  echo "   <packagereq type=\"default\">$name</packagereq>"
  echo "   <packagereq type=\"optional\">$name-archives</packagereq>"
done

echo '  </packagelist>'
echo ' </group>'
echo ' <category>'
echo "  <id>srpmix</id>"
echo "  <name>SRPMix</name>"
echo "  <display_order>99</display_order>"
echo "  <grouplist>"
echo "   <groupid>srpmix-$DIST</groupid>"
echo "  </grouplist>"
echo ' </category>'
echo '</comps>'


