function svn_p
{
    test -d .svn
}

function svn_make_checkout_cmdline
{

    local repo=$1
    local package=$2
    local branch=$3
    
    
    echo svn checkout "$repo" $(lcopy_make_pb_name "${package}" "${branch}")
}

function svn_checkout
{

    local repo=$1
    local dir=$2
    
    
    echo svn checkout "$repo" "$dir"
}

function svn_update
{
    local log=$1
    which svn > /dev/null 2>> "$log" && svn update
}

function svn_generate_rebirth_cmdline
{
    local svn_info=`svn info`
    if test $? != 0; then
	echo "fail in 'svn info' invocation" 1>&2
	pwd 1>&2
	return 1
    fi

    local svn_url=`echo "$svn_info" | grep 'URL: ' |  sed -e 's/URL: //'`
    if test "x${svn_url}" = x; then
	echo "cannot find URL line in svn_info output" 1>&2
	pwd 1>&2
	return 1
    fi
    
    local top_dir=`pwd`
    local svn_dir=$(basename ${top_dir})

    echo "# [0] ${top_dir}"
    echo "svn checkout ${svn_url} ${svn_dir}"
    return 0
}

function svn_to_pkg
{
    echo subversion
}

: lcopy-svn.bash ends here
