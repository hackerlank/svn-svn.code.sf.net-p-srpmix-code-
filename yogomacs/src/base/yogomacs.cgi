#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"
(use www.cgi)
(use yogomacs.main)

(cgi-main (pa$ yogomacs *argv*))
