#!/bin/bash
#
# pfor.sh --- Run command in parallel
#

# THIS IS FOR LINUX.
pfor_max_processors=$(cat /proc/cpuinfo | grep ^processor | wc -l)

function pfor_usage
{
    echo "Usage: pfor [-h|--help] [-p=N|--processes=N] cmd args..."
    echo "Run command in parallel"
    echo ""
    echo " -p=N"
    echo "--processes=N	the number of processes run in parallel"
    echo "              If \`-\' is specified, the number of"
    echo "              processors on the system is used as N."
    echo ""
    echo "Example:"
    echo "X=\"a b c d e f g h i j k l m n A B C D E F G H I J K L M N\""
    echo "cd /tmp; for x in $X; do echo $x; done | pfor mkdir -p"
    echo "cd /tmp; for x in $X; do echo $x; done | pfor rmdir"
}

function pfor
{
    local n_processor=-


    if [[ -z "$1" ]]; then
	pfor_usage 1>&2
	return 1
    fi
    
    while true; do
	case $1 in
	    -h|--help)
		pfor_usage
		return 0
		;;
	    -p=*)
		n_processor=${1/-p=/}
		shift
		;;
	    --processes=*)
		n_processor=${1/--processes=/}
		shift
		;;
	    *)
	        break;
		;;
	esac
    done

    case "${n_processor}" in
	-)
	    n_processor="${pfor_max_processors}"
	    ;;
	0)
	    return 0
	    ;;
	[1-9]|[1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9])
	    break
	    ;;
	*)
	    pfor_usage 1>&2
	    return 1
    esac

    i=0; while (( i < n_processor )); do
	(( i++ ))
	read && [[ -z "${REPLY}" ]] && break
	"$@" "${REPLY}" &
    done

    wait; while read; do
	[[ -z "${REPLY}" ]] && break
	"$@" "${REPLY}" &
	wait
    done

    i=1; while (( i < n_processor )); do
	(( i++ ))
	wait
    done

    return 0
}

pfor "$@"
# pfor.sh ends here
