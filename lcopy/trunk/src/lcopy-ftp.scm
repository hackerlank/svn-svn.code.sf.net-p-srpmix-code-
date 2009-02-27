#!/usr/bin/evn gosh

(use rfc.ftp)
(use gauche.version)


(define current "patch-2.6.4.bz2.sign")
;(define host "ibiblio.org")
(define host "ftp.kernel.org")
;(define dir  "/pub/linux/system/status")
(define dir  "/pub/linux/kernel/v2.6")
(define passive? #t)


;(define prefix  "sysstat")
(define prefix  "patch")
;(define suffix  "tar.gz")
(define suffix  "bz2.sign")


(define prefix-regexp (string->regexp (string-append "\\s?(" (regexp-quote prefix) "\\S+" ")")))
(define suffix-regexp (string->regexp (string-append ".*" (regexp-quote suffix) "$")))

(call-with-ftp-connection host
 (lambda (conn)
   (ftp-chdir conn dir)
   (let1 sorted (sort (fold (lambda (line gather)
			      (rxmatch-if (prefix-regexp line)
				  (#f file)
				(if (suffix-regexp file)
				    (cons file gather)
				    gather)
				gather) )
			    (list)
			    (ftp-list conn))
		      version>?)
     (if (and (not (null? sorted))
	      (version>? (car sorted) current))
	 (write (ftp-get conn (car sorted)))
	 (write "failed to get"))))
 :passive passive?)

		 

			  