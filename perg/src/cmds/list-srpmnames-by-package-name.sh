#! /bin/bash
#
# Copyright (C) 2010 Masatake YAMATO <yamato@redhat.com>
# Copyright (C) 2010 Satoru SATOH <satoru.satoh@gmail.com>
# Lincense: GPLv3+
#

set -e
#set -x
 
sqlite="/usr/bin/sqlite3"
usage="Usage: $0 sqldb pkgname"
 
if test ! -x $sqlite; then
echo $usage
    exit 1
fi
 
sqldb=$1
pkgname=$2
if test -z "$pkgname"; then
echo $usage
    exit 1
fi

sql="SELECT DISTINCT p.srpmname FROM packages as p WHERE p.name = \"$pkgname\""
 
$sqlite $sqldb "$sql" | sort | uniq
 
# vim: set sw=4 ts=4 et:
