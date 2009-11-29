#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"
(use gauche.net)
(us gauche.parseopt)

(define (complete partial)
  partial)


(define (build-acceptor unacceptable-ip-list0 acceptable-path-regex0)
  (let (
	(unacceptable-ip-list    (map inet-string->address unacceptable-ip-list0))
	(acceptable-path-regex   (string->regexp acceptable-path-regex0))
	)
    (lambda (ip file)
      (if (memq ip unacceptable-ip-list)
	  #f
	  (if (acceptable-path-regex file)
	      #t
	      #f)))))

(define (main args)
  (let ((accept? (build-acceptor '("192.168.11.41" "127.0.0.1")
				 "^var/lib/srpmix/sources/[0-9a-zA-Z]/[^/]+/[^/]+/.+"))
	(sstat-dir "/srv/sources/attic/sstat"))

    (when file-is-directory? sstat-dir
	  (errorf "No such directory: ~a" sstat-dir))

    (run accept? sstat-dir)))

(define (format-port-name sstat-dir tmf)
  (format "~a/sstat-~a.es" sstat-dir tmf))

(define (run accept? sstat-dir)
  (let loop ((line (read-line))
	     (port #f)
	     (tmf  #f)
	     (ip    "0.0.0.0")
	     (time  0))
    (unless (eof-object? line)
      (rxmatch-if (#/^([0-9]+) (.*)\/$/ line)
	  (#f ip file)
	;; 
	(let1 ip (string->number ip)
	  (when (accept? ip file)
	    (let1 time (sys-time)
	      (receive (port tmf) (log-port time port tmf sstat-dir)
		(write `(nfsd-open-pre :ip ,ip :time ,time :path ,file)
		       port)
		(newline port)
		(loop (read-line) port tmf ip time))))
	  (loop (read-line) port tmf ip time))
	(begin 
	  (format (current-error-port) ";; Wrong input: ~s\n" line)
	  (loop (read-line) port tmf ip time))))))

(define (log-port time port tmf sstat-dir)
  (let1 tm0 (sys-localtime time)
    (let1 tmf0 (format "~d~d~d" 
		       (+ (ref tm0 'year) 1900)
		       (+ (ref tm0 'mon) 1)
		       (ref tm0 'mday))
      (cond
       ((equal? tmf tmf0)
	(values port tmf))
       ((not tmf)
	(values (open-output-file (format-port-name sstat-dir tmf0)
				  :if-exists :append
				  :buffering :line)
		tmf0))
       (else
	(close-output-port port)
	(values (open-output-file (format-port-name sstat-dir tmf0))
		tmf0))))))
