function cvs_p
{
    test -d CVS
}

function cvs_make_checkout_cmdline
{

    local repo=$1
    local package=$2
    local branch=$3
    local module=$4
    
    echo cvs -d${repo} checkout -P -d $(lcopy_make_pb_name "${package}" "${branch}") ${module} 
    
}

function cvs_checkout
{
    local repo=$1
    local dir=$2
    local module=$3

    echo cvs -d${repo} checkout -P -d ${dir} ${module} 
}

function cvs_update
{
    local log=$1
    which cvs > /dev/null 2>> "$log" && cvs update -d
}

#
# CVS
#
function cvs_generate_rebirth_cmdline
{
    local cvs_root=
    local cvs_repo=
    local top_dir=`pwd`
    local cvs_dir=$(basename  ${top_dir})
    local cvs_root_rx=
    local cvs_pass=

    (cd CVS; 
	if test -f Root; then
	    cvs_root=`cat Root`
	else
	    echo "cannot find cvs Root file" 1>&2
	    pwd 1>&2
	    return 1
	fi

	if test -f Repository; then
	    cvs_repo=`cat Repository`
	else
	    echo "cannot find cvs Repository file" 1>&2
	    pwd 1>&2
	    return 1
	fi


	echo "# [0] ${top_dir}"
	
	cvs_root_rx=`echo ${cvs_root} | sed -e 's|\(.*\):/\(.*\)|\1:[0-9]*/\2|'`
	cvs_pass=`grep "${cvs_root_rx}" ~/.cvspass 2>/dev/null`
	if [ $? == 0 ]; then
            cat <<EOF
fgrep '${cvs_pass}' ~/.cvspass > /dev/null 2>&1 \\
|| echo '${cvs_pass}' >> ~/.cvspass
EOF
        else
	    echo "# [1] cannot find password entry for ${top_dir}"
	fi

	echo cvs -d"${cvs_root}" checkout -P -d ${cvs_dir} ${cvs_repo}
	return 0
	)
}

function cvs_to_pkg
{
    echo cvs
}

: lcopy-cvs.bash ends here