########################################################################
#
# liblcopy.sh: support shell functions for lcopy
#
# Copyright (C) 2007 Masatake YAMATO
#
# Author: Masatake YAMATO <yamato@redhat.com>
#
# program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################

function lcopy_is_arch
{
    test -d '{arch}'
}

function lcopy_is_bzr
{
    test -d .bzr
}

function lcopy_is_cvs
{
    test -d CVS
}

function lcopy_is_darcs
{
    test -d _darcs
}

function lcopy_is_git
{
    test -d .git
}

function lcopy_is_hg
{
    test -d .hg
}

#
# See http://www.openembedded.org/wiki/GettingStarted
#
function lcopy_is_mtn
{
    for m in *.mtn; do
	if test -f "${m}"; then
	    return 0
	fi
    done

    return 1
}

function lcopy_is_mtn_lcopy
{
    test -d _MTN
}

function lcopy_is_svn
{
    test -d .svn
}


########################################################################
#
function es_echo_n
{
    printf "%s" "$*"
}
#
########################################################################

########################################################################
#
# es_time
#
function es_time
{
    TIMEFORMAT=$'(time :real %R :user %U :sys %S)' 
    time $@
    return $?
}
#
########################################################################


########################################################################
#
# es_print is taken from es-lang-sh-print. 
#
function es_print
{
    es_print_value=no


    es_echo_n "("

    while [ $# -gt 0 ]; do
	case "$1" in 
	    --*=*)
                if test ${es_print_value} = yes; then
		    es_echo_n ") "
		fi

                es_echo_n "`echo $1 | sed -e 's/^--\([^=]*\)=\(.*\)$/:\1 \2/'` "
		es_print_value=no

		shift
		;;
	    --*)
		if test ${es_print_value} = yes; then
		    es_echo_n ") "
		    es_print_value=no
		fi
		
		es_echo_n "`echo $1 | sed -e 's/^--/:/'` "
		es_print_value=yes
		es_echo_n "("

		shift
		;;
	    -*=*)
                if test ${es_print_value} = yes; then
		    es_echo_n ") "
		fi

                es_echo_n "`echo $1 | sed -e 's/^-\([^=]*\)=\(.*\)$/:\1 \2/'` "
		es_print_value=no

		shift
		;;
	    -*)
		if test ${es_print_value} = yes; then
		    es_echo_n ") "
		    es_print_value=no
		fi
		
		es_echo_n "`echo $1 | sed -e 's/^-/:/'` "
		es_print_value=yes
		es_echo_n "("

		shift
		;;
	    *)
		es_echo_n "$1 "
		shift
		;;
	    esac
    done
    
    if test ${es_print_value} = yes; then
	    es_echo_n ")"
	    es_print_value=no
    fi
    echo ")"
}
#
########################################################################

: libcopy.sh ends here
