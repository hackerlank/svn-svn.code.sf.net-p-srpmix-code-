#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(use gauche.net)

(define (make-readable ip)
  ;; (ip    (inet-address->string (string->number (match 1)) AF_INET))
  ip)

(define (complete partial)
  partial)

(define (main args)
  (let loop ((line (read-line)))
    (unless (eof-object? line)
      (let1 match (#/([0-9]+) (.*)\/$/ line)
	(if match
	    (let (
		  (ip    (make-readable (match 1)))
		  (time  (sys-time))
		  (file  (complete (match 2))))
	      ;;
	      (write `(nfsd-open-pre :ip ,ip :time ,time :path ,file))
	      (newline)
	      )
	    (format (current-error-port) ";; Wrong input: ~s\n" line)
	    ))
      (loop (read-line)))))
