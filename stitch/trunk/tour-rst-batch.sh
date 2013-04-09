#!/bin/bash
# tour-rst-batch.sh --- convert a tour to a rst file

# Copyright (C) 2013 Red Hat, Inc.
# Copyright (C) 2013 Masatake YAMATO

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

help()
{
    local status=$1

    echo "Usage: "
    echo
    echo "	$0 -h|--help"
    echo "	$0 TOUR-FILE.es TOUR-NAME OUTPUT-FILE.rst"
    echo
    exit $status
}

tour_rst()
{
    emacs --batch -l ~/.emacs.d/init.el -l tour -l stitch -l $1 --eval \
	"(tour-rst-batch \"$2\" \"$3\" t)"
}

main()
{
    local input_file=$1
    local tour_name=$2
    local output_file=$3

    while [[ $# -gt 0 ]]; do
	case $1 in
	    -h|--help)
		help 0
		;;
	    -*)
		echo "unknown option: $1" 1>&2
		help 1
		;;
	    *)
		break
		;;
	esac
    done
    
    if [[ -z "${input_file}" ]]; then
	echo "input file name is not given" 1>&2
	help 2 1>&2
    fi
    
    if [[ ! -r "${input_file}" ]]; then
	echo "cannot read ${input_file}" 1>&2
	exit 1
    fi
    
    if [[ -z "${tour_name}" ]]; then
	echo "tour name is not given" 1>&2
	help 2 1>&2
    fi

    if [[ -z "${output_file}" ]]; then
	echo "output file name is not given" 1>&2
	help 2 1>&2
    fi

    tour_rst "${input_file}" "${tour_name}" "${output_file}"
    return $?
}

# ./tour.es Mapped-in-meminfo /tmp/Mapped-in-meminfo.rst


main "$@"
