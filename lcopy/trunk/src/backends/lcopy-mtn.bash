#
# Monotone
#
# See http://www.openembedded.org/wiki/GettingStarted
#
function mtn_p
{
    for m in *.mtn; do
	if test -f "${m}"; then
	    return 0
	fi
    done

    return 1
}

#
# Monotone
#
# See http://www.openembedded.org/wiki/GettingStarted
#

function mtn_update
{
    local r=
    local mtn_db=

    
    if ! which mtn > /dev/null; then
	return 1
    fi

    for m in *.mtn; do
	if test -f "${m}"; then
	    mtn_db="`pwd`/${m}"
	fi
    done

    if test x = "x${mtn_db}"; then
	return 1
    fi

    mtn --db="${mtn_db}" pull
    r=$?

    if test $r != 0; then
	return $r
    fi

    for d in *; do
	if test -d "${d}"; then
	    (refresh "${d}")
	fi
    done

    return 0
}

: lcopy-mtn.bash