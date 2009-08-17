function git_p
{
    test -d .git
}

function git_checkout
{

    local repo=$1
    local dir=$2
    
    echo git clone "$repo" "$dir"
}

function git_checkout_parse_cmdline
{
    VCS=$1
    CMD=$2
    REPO=$3
    PACKAGE=$4

    if test "x$VCS" != xgit; then
	echo "wrong vcs: $VCS" 1>&2
	return 1
    fi

    if test \( -z "$CMD"          \) -o    \
            \( "$CMD" != clone \) ; then
	echo "broken git command line: $@" 1>&2
	return 1
    fi

    if test -z "$REPO"; then
	echo "no repository" 1>&2
	return 1
    fi

 
# TODO
#    if test "x$(echo $REPO | sed -e 's/[^:]//g')" != "x::::"; then
#	echo "broken repo specification: $REPO" 2>&1
#	print_usage 2>&1
#	exit 1
#    fi

    if test -z "$PACKAGE"; then
	echo "no packagedir" 1>&2
	return 1
    fi

    return 0
}

function git_checkout_print_usage
{
    echo "	" git clone REPOS PACKAGEDIR
}


function git_update
{
    local log=$1
    which git > /dev/null && git pull
}

function git_rebirth
{
    local git_remote_origin_proc="`git-config  --get remote.origin.url`"
    local git_branches_origin_file="`pwd`/.git/branches/origin"
    local git_remotes_origin_file="`pwd`/.git/remotes/origin"

    local git_origin=

    if test -n "${git_remote_origin_proc}"; then
	git_origin="${git_remote_origin_proc}"
    elif test -r "${git_branches_origin_file}"; then
	git_origin=`cat ${git_branches_origin_file}`
    elif test -r "${git_remotes_origin_file}"; then
	git_origin=`cat ${git_remotes_origin_file} | grep URL: | sed -e 's/URL: //'`
    else
	echo "cannot read origin file: ${git_branches_origin_file}" 1>&2
	echo "cannot read origin file: ${git_remotes_origin_file}" 1>&2
	echo "git-config for `remote.origin.url` returns nothing" 1>&2
	pwd 1>&2
	return 1
    fi

    local top_dir=`pwd`
    echo "# [0] ${top_dir}"
    echo "git-clone ${git_origin} `basename ${top_dir}`"
    return 0
}

function git-clone_checkout_parse_cmdline
{
    shift 1
    git_checkout_parse_cmdline git clone "$@"
}

function git-clone_checkout_print_usage
{
    echo "	" git-clone REPOS PACKAGEDIR
}

: lcopy-git.bash ends here