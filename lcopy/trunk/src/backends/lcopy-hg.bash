function hg_p
{
    test -d .hg
}

function hg_make_checkout_cmdline
{

    local repo=$1
    local package=$2
    local branch=$3
    
    echo hg clone "$repo" $(lcopy_make_pb_name "${package}" "${branch}")
}

function hg_checkout
{

    local repo=$1
    local dir=$2
    
    echo hg clone "$repo" "$dir"
}

function hg_update
{
    local log=$1
    which hg > /dev/null 2>> $log && hg update
} 

function hg_generate_rebirth_cmdline
{
    local hg_path=`hg showconfig -u paths.default 2> /dev/null`
    if test $? != 0; then
	echo "fail in 'hg showconfig' invocation" 1>&2
	pwd 1>&2
	return 1
    fi

    local top_dir=`pwd`
    echo "# [0] ${top_dir}"
    echo "hg clone ${hg_path} `basename ${top_dir}`"
    return 0
}

function hg_to_pkg
{
    echo mercurial
}

: lcopy-hg.bash ends here
