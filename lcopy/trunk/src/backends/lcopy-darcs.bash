function darcs_p
{
    test -d _darcs
}

function darcs_checkout
{
    local repo=$1
    local dir=$2

    echo darcs get "$repo" "$dir"
}

function darcs_checkout_parse_cmdline
{
    VCS=$1
    CMD=$2
    REPO=$3
    PACKAGE=$4

    if test "x$VCS" != xdarcs; then
	echo "wrong vcs: $VCS" 1>&2
	return 1
    fi
    
    if test \( -z "$CMD"          \) -a    \
        \( "$CMD" != get \) ; then
	echo "broken darcs command line: $@" 1>&2
	return 1
    fi

    if test -z "$REPO"; then
	echo "no repository" 1>&2
	return 1
    fi

    if test -z "$PACKAGE"; then
	echo "no packagedir" 1>&2
	return 1
    fi

    return 0
}

function darcs_checkout_print_usage
{
    echo "	" darcs get REPOS PACKAGEDIR
}

function darcs_update
{
    which darcs > /dev/null && darcs pull -a 
}

function darcs_rebirth
{
    local darcs_defaultrepo_file="`pwd`/_darcs/prefs/defaultrepo"
    local darcs_defaultrepo=

    if test ! -r "${darcs_defaultrepo_file}"; then
	echo "canot read defaultrepo file: ${darcs_defaultrepo_file}" 1>&2
	pwd 1>&2	
	return 1
    fi

    darcs_defaultrepo=`cat ${darcs_defaultrepo_file}`

    local top_dir=`pwd`
    echo "# [0] ${top_dir}"
    echo "darcs get ${darcs_defaultrepo} `basename ${top_dir}`"
    return 0
}

: lcopy-darcs.bash ends here
