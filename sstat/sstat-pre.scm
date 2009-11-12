#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(define (main args)
  (let loop ((line (read-line)))
    (unless (eof-object? line)
      (let1 match (#/([0-9]+) (.*)$/ line)
	(if match
	    )
      (loop (read-line))
      )))
;; IP FILE