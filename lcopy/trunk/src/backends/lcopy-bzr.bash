#
# Bazzar NG
#

function bzr_p
{
    test -d .bzr
}

function bzr_make_checkout_cmdline
{

    local repo=$1
    local package=$2
    local branch=$3
    
    bzr_checkout "$repo" $(lcopy_make_pb_name "${package}" "${branch}")
}

function bzr_checkout
{
    local repo=$1
    local dir=$2

    echo bzr branch "$repo" "$dir"
}

function bzr_update
{
    local log=$1
    which bzr > /dev/null 2>> "$log" && bzr update
}

function bzr_generate_rebirth_cmdline
{
    local bzr_location=`bzr info | grep -e 'parent branch:' | sed -e 's/  parent branch: //'`
    echo bzr branch ${bzr_location} `pwd`
}

function bzr_to_pkg
{
    echo bar
}

: lcopy-bzr.bash ends here