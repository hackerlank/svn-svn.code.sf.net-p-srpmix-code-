function darcs_p
{
    test -d _darcs
}

function darcs_update
{
    local log=$1
    which darcs > /dev/null 2>> "$log" && darcs pull -a 
}

function darcs_generate_rebirth_cmdline
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

:lcopy-darcs.bash ends here
