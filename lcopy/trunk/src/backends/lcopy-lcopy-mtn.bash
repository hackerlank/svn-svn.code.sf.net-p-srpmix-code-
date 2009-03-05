function mtn_lcopy_p
{
    test -d _MTN
}

function mtn_lcopy_update
{
    local log=$1
    which mtn > /dev/null 2>> $log && mtn update
}

: lcopy-lcopy-mtn.bash ends here
