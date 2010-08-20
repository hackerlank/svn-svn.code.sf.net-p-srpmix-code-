#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(use gauche.test)
(define *test-report-error* #t)
(test-start "Yogomacs lcopy test")

(use yogomacs.util.lcopy)

(test* "update"
       #f
       (lcopy-dir->no-update? "/srv/sources/sources/k/kernel/^lcopy-trunk"))

(exit (if (zero? (test-end)) 0 1))