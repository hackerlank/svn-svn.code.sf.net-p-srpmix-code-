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
(use srfi-1)

(define (read-line-safe . args)
  (guard (e
	  (else ""))
	 (read-line   
	  (if (null? args) (current-input-port) (car args)))))

(define (print-help prog status)
  (display "Usage: \n")
  (format #t "	gosh ~s adjust DELTA < /var/log/messages\n" prog)
  (format #t "	cat /var/log/messages0 /var/log/messages1 /var/log/messages2 | gosh ~s sort \n" prog)
  (format #t "	gosh ~s help\n" prog)
  (format #t "	gosh ~s --help\n" prog)
  (exit status))

(define (string->date+year date-string year)
  (string->date (string-append 
		 year
		 " " date-string) "~y ~b ~d ~H:~M:~S"))

(define (format-date date)
  (date->string date "~b ~d ~H:~M:~S"))

(define (rearrange-date date-string delta year)
  (format-date (time-utc->date
    (add-duration (date->time-utc (string->date+year date-string year))
		  delta))))

(define var-log-message-line-regex
  #/^([A-Z][a-z][a-z] [0-9]+ [0-9]{2}:[0-9]{2}:[0-9]{2}) ([-a-z0-9]+) ([^\[\]\/]+)(\[[0-9]+\])?: (.*)$/)
(define var-log-message-repeated-line-regex
  #/^([A-Z][a-z][a-z] [0-9]+ [0-9]{2}:[0-9]{2}:[0-9]{2}) ([-a-z0-9]+) (last message repeated [0-9]+ times)$/)
(define var-log-message-signal-line-regex
  #/^([A-Z][a-z][a-z] [0-9]+ [0-9]{2}:[0-9]{2}:[0-9]{2}) ([-a-z0-9]+) (exiting on signal [0-9]+)$/)

(define (emit-log-line date host cmd pid msg)
  (format #t
	  "~a ~a ~a ~a~a ~a\n"
	  date
	  host
	  (or cmd "")
	  (or pid "")
	  (if pid ":" "")
	  msg
	  ))

(define (do-adjust args)
  (let* ((delta (let1 d (string->number (cadr args))
		  (unless d
		    (with-output-to-port (current-error-port)
		      (cute print-help (car args) 1)))
		  (make <time> :type 'time-duration :second d)))
	 (year (date->string (time-utc->date (current-time)) "~y"))
	 (rearrange-date$ (cute rearrange-date <> delta year)))
    (let loop ((l (read-line-safe)))
      (unless (eof-object? l)
	(rxmatch-cond
	  ((var-log-message-line-regex l)
	   (#f date host cmd pid msg)
	   (emit-log-line (rearrange-date$ date) 
			  host 
			  cmd
			  pid
			  msg))
	  ((var-log-message-repeated-line-regex l)
	   (#f date host msg)
	   (emit-log-line (rearrange-date$ date) 
			  host 
			  #f
			  #f
			  msg))
	  ((var-log-message-signal-line-regex l)
	   (#f date host msg)
	   (emit-log-line (rearrange-date$ date) 
			  host 
			  #f
			  #f
			  msg)))
	(loop (read-line-safe))))))

(define (do-sort args)
  (let* ((year (date->string (time-utc->date (current-time)) "~y"))
	 (string->date+year$ (cute string->date+year <> year)))
    (for-each
     (lambda (elt)
       (apply emit-log-line  (cons (format-date 
				    (time-utc->date (car elt)))
				   (cdr elt))))
     (stable-sort!
      (map (lambda (l)
	     (rxmatch-cond
	       ((var-log-message-line-regex l)
		(#f date host cmd pid msg)
		(list (date->time-utc (string->date+year$ date))
		      host 
		      cmd
		      pid
		      msg))
	       ((var-log-message-repeated-line-regex l)
		(#f date host msg)
		(list (date->time-utc (string->date+year$ date))
		      host 
		      #f
		      #f
		      msg))
	       ((var-log-message-signal-line-regex l)
		(#f date host msg)
		(list (date->time-utc (string->date+year$ date))
		      host 
		      #f
		      #f
		      msg))
	       (else
		#?=l)
	       ))
	   (delete! "" 
		    (port->list read-line-safe (current-input-port))
		    equal?))
      (lambda (a b)
	(if (time=? (car a) (car b))
	    (if (string=? (cadr a) (cadr b))
		#f
		(string<? (cadr a) (cadr b)))
	    (time<? (car a) (car b))))))))

(define (main args)
  (unless (<= 2 (length args))
    (with-output-to-port (current-error-port)
      (cute print-help (car args) 1)))
  (when (or (equal? (cadr args) "-h")
	    (equal? (cadr args) "--help")
	    (equal? (cadr args) "help"))
    (print-help (car args) 0))

  (case (string->symbol (cadr args))
    ('adjust
     (do-adjust (cons (car args) (cddr args))))
    ('sort
     (do-sort (cons (car args) (cddr args))))
     ))

