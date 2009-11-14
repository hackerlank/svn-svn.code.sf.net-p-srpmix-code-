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
  (let loop ((line (read-line))
	     (port #f)
	     (tmf  #f))
    (unless (eof-object? line)
      (rxmatch-if (#/^([0-9]+) (.*)\/$/ line)
	  (#f ip file)
	(let1 time (sys-time)
	  (receive (port tmf) (log-port time port tmf)
	    (write `(nfsd-open-pre :ip ,(string->number ip) :time ,time :path ,file)
		   port)
	    (newline port)
	    (loop (read-line) port tmf)))
	(begin 
	  (format (current-error-port) ";; Wrong input: ~s\n" line)
	  (loop (read-line) port tmf))))))

(define (format-port-name tmf)
  (format "/tmp/sstat-~a.es" tmf))

(define (log-port time port tmf)
  (let1 tm0 (sys-localtime time)
    (let1 tmf0 (format "~d~d~d" 
		       (+ (ref tm0 'year) 1900)
		       (+ (ref tm0 'mon) 1)
		       (ref tm0 'mday))
      (cond
       ((equal? tmf tmf0)
	(values port tmf))
       ((not tmf)
	(values (open-output-file (format-port-name tmf0))
		tmf0))
       (else
	(close-output-port port)
	(values (open-output-file (format-port-name tmf0))
		tmf0))))))