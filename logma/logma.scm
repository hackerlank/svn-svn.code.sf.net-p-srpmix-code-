;;; logma.scm --- simple log manipulator
;;
;;  Copyright (C) 2009 Red Hat, Inc. All rights reserved.
;;  Copyright (C) 2009 Masatake YAMATO, Inc. All rights reserved.
;;
;;  This program is free software; you can redistribute it and/or modify it
;;  under the terms of the GNU General Public License as published by the
;;  Free Software Foundation; either version 2, or (at your option) any
;;  later version.
;;
;;  This program is distributed in the hope that it will be useful, but
;;  WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;  General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program; see the file COPYING.  If not, write to the
;;  Free Software Foundation, Inc.,  675 Mass Ave, Cambridge,
;;  MA 02139, USA.
;;
(use srfi-19)

(define (read-line-safe)
  (guard (e
	  (else ""))
	 (read-line)))

(define (print-help prog status)
  (display "Usage: \n")
  (format #t "	gosh ~s DELTA < /var/log/messages\n" prog)
  (format #t "	gosh ~s --help\n" prog)
  (exit status))

(define (rearrange-date date-string delta)
  (date->string 
   (time-utc->date
    (add-duration (date->time-utc
		   (string->date (string-append 
				  (date->string (time-utc->date (current-time)) "~y")
				  " " date-string) "~y ~b ~d ~H:~M:~S"))
		  delta))
   "~b ~d ~H:~M:~S"))

(define var-log-message-line-regex
  #/^([A-Z][a-z][a-z] [0-9]+ [0-9]{2}:[0-9]{2}:[0-9]{2}) ([-a-z0-9]+) ([^\[\]\/]+)(\[[0-9]+\])?: (.*)$/)

(define emit-log-line (date host cmd pid msg)
  (format #t
	  "~a ~a ~a ~a: ~a\n"
	  date
	  host
	  cmd
	  (or pid "")
	  msg
	  ))

(define (main args)
  (unless (eq? 2 (length args))
    (with-output-to-port (current-error-port)
      (cute print-help (car args) 1)))
  (when (or (equal? (cadr args) "-h")
	    (equal? (cadr args) "--help"))
    (print-help (car args) 0))

  (let1 delta (let1 d (string->number (cadr args))
		(unless d
		  (with-output-to-port (current-error-port)
		    (cute print-help (car args) 1)))
		(make <time> :type 'time-duration :second d))
    (let loop ((l (read-line-safe)))
      (unless (eof-object? l)
	(rxmatch-cond
	  ((var-log-message-line-regex l)
	   (#f date host cmd pid msg)
	   (emit-log-line (rearrange-date date
					  delta) 
			  host 
			  cmd
			  pid
			  msg)))
	(loop (read-line-safe))))))

