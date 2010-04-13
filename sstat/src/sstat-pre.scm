#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"
(use gauche.net)
(use gauche.parseopt)
(use srfi-1)
(use file.util)


(define (complete partial)
  partial)

(define (build-acceptor unacceptable-ip-list0 acceptable-path-regex0)
  (let (
	(unacceptable-ip-list (delete-duplicates 
			       (map inet-string->address 
				    (apply append
					   (map (cute ref <> 'addresses)
						(map sys-gethostbyname
						     unacceptable-ip-list0))))
			       equal?))
	(acceptable-path-regex   (string->regexp acceptable-path-regex0))
	(multiaccess-table       (make-hash-table 'eq?))
	)
    (lambda (ip file time)
      (if (memq ip unacceptable-ip-list)
	  #f
	  (if (let1 last-access-file (hash-table-get multiaccess-table ip #f)
		(hash-table-put! multiaccess-table ip file)
		(not (equal? last-access-file file)))
	      (acceptable-path-regex file)
	      #f)))))


(define (print-usage prog-name port exit-status)
  (format port "Usage: \n")
  (format port "~a -h|--help\n" prog-name)
  (format port "~a --sstat-dir=DIR --acceptable-regex=REGEX [IP-ADDRESS]...\n" prog-name)
  (sys-exit exit-status))

(define (main args)
  (let-args (cdr args)
      ((help      "h|help" => (cut print-usage (car args) (current-output-port) 0))
       (sstat-dir "sstat-dir=s" #f)
       (acceptable-regex "acceptable-regex=s" #f)
       . ips)
    (if sstat-dir
	(unless (file-is-directory? sstat-dir)
	      (errorf "No such directory: ~a" sstat-dir))
	(print-usage (car args) (current-error-port) 1))
    (unless acceptable-regex
      (print-usage (car args) (current-error-port) 1))

    (let1 ips (if (member "127.0.0.1" ips)
		  ips
		  (reverse (cons "127.0.0.1" (reverse ips))))
      (let1 accept? (build-acceptor ips acceptable-regex)
	(run accept? sstat-dir)))))


(define (format-port-name sstat-dir year month tmf)
  (let1 dir (format "~a/~a/~a" sstat-dir year month)
    (make-directory* dir)
    (format "~a/sstat-~a.es" dir tmf)))


(define (read-line-safe . port)
  (let1 port (if (null? port)
		 (current-input-port)
		 (car port))
    (guard (e
	    (else #f))
	   (read-line port))))

(define (run accept? sstat-dir)
  (let loop ((line (read-line-safe))
	     (port #f)
	     (tmp  #f)
	     (ip    "0.0.0.0")
	     )
    (cond
     ((not line) (loop (read-line-safe) port tmp ip))
     ((not (eof-object? line))
      (rxmatch-if (#/^([0-9]+) ([0-9]+) (.*)\/$/ line)
	  (#f ip time file)
	;; 
	(let ((ip (string->number ip))
	      (time (string->number time)))
	  (when (accept? ip file time)
	      (receive (port tmf) (log-port time port tmf sstat-dir)
		(write `(nfsd-open-pre :ip ,ip :time ,time :path ,file)
		       port)
		(newline port)
		(loop (read-line-safe) port tmf ip)))
	  (loop (read-line-safe) port tmf ip))
	(begin 
	  (format (current-error-port) ";; Wrong input: ~s\n" line)
	  (loop (read-line-safe) port tmf ip)))))))

(define (log-port time port tmf sstat-dir)
  (let1 tm0 (sys-localtime time)
    (let ((tmf0 (format "~d~2,'0d~2,'0d" 
		       (+ (ref tm0 'year) 1900)
		       (+ (ref tm0 'mon) 1)
		       (ref tm0 'mday)))
	  (y    (format "~d"      (+ (ref tm0 'year) 1900)))
	  (m    (format "~2,'0d"  (+ (ref tm0 'mon) 1))))
      (cond
       ((equal? tmf tmf0)
	(values port tmf))
       ((not tmf)
	(values (open-output-file (format-port-name sstat-dir y m tmf0)
				  :if-exists :append
				  :buffering :line)
		tmf0))
       (else
	(close-output-port port)
	(values (open-output-file (format-port-name sstat-dir y m tmf0)
				  :if-exists :append
				  :buffering :line)
		tmf0))))))

