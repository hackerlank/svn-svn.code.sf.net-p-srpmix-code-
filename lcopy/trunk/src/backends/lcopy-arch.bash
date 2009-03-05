#
# Arch: _make_checkout_cmdline, _checkout
#
function arch_p
{
    test -d '{arch}'
}

function arch_update
{
    local log=$1

    if which baz >/dev/null 2>/dev/null; then
	baz replay
    elif which tla > /dev/null 2>/dev/null; then
	tla replay
    else
	echo "both tla and baz are not found" 2>> "$log" 1>&2 
	return 1
    fi
}
: lcopy-arch.bash