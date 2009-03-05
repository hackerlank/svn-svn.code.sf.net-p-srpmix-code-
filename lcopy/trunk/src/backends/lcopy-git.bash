function git_p
{
    test -d .git
}

function git_make_checkout_cmdline
{

    local repo=$1
    local package=$2
    local branch=$3
    
    echo git clone "$repo" $(lcopy_make_pb_name "${package}" "${branch}")
}

function git_checkout
{

    local repo=$1
    local dir=$2
    
    echo git clone "$repo" "$dir"
}

function git_update
{
    local log=$1
    which git > /dev/null 2>> $log && git pull
}

function git_generate_rebirth_cmdline
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

function git_to_pkg
{
    echo git
}

: lcopy-git.bash ends here