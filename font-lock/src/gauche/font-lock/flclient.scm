(define-module font-lock.flclient
  (export flclient-ping
	  flclient-xhtmlize
	  flclient-shtmlize
	  flclient-cssize
	  flclient-shutdown)
  (use gauche.process)
  (use srfi-1)
  (use util.match)
  )
(select-module font-lock.flclient)


;; (define replace-keyword (match-lambda*
;; 			 ((args key val replace?)
;; 			  (guard (e
;; 				  (else (cons* key val args)))
;; 				 (let1 oval (get-keyword key args)
;; 				   (if (replace? oval)
;; 				       (cons* key val (delete-keyword key args))
;; 				       args))))
;; 			 ((args key val)
;; 			  (replace-keyword args key val not))))

(define (flclient-do common-args default-timeout expression)
  (let-keywords common-args ((emacsclient :emacsclient "emacsclient")
			     (socket-name :socket-name "flserver")
			     (verbose :verbose #f)
			     (timeout :timeout default-timeout))
		(invoke-emacsclient emacsclient
				    socket-name
				    verbose
				    timeout
				    expression
				    )))

(define (flclient-ping . rest)
  (flclient-do rest 1 `(flserver 'ping)))

(define (flclient-xhtmlize src-file html-file css-dir . rest)
  (flclient-do rest 60 `(flserver 'xhtmlize ,src-file ,html-file ,css-dir)))

(define (flclient-shtmlize src-file shtml-file css-dir . rest)
  (flclient-do rest 60 `(flserver 'shtmlize ,src-file ,shtml-file ,css-dir)))

(define (flclient-cssize face css-dir requires . rest)
  (flclient-do rest 10 `(flserver 'cssize ',face ,css-dir ',requires)))

(define (flclient-shutdown . rest)
  (flclient-do rest 60 `(flserver 'shutdown)))

(define (invoke-emacsclient emacsclient socket-name verbose timeout expression)
  (let1 proc (run-process (list emacsclient
				(format "--socket-name=~a" socket-name)
				"--eval" (format "~s" expression))
			  :wait #f
			  :error (if verbose #f "/dev/null"))
    ;;
    (if (number? timeout)
	(let1 total-sleep 0
	  (until (process-wait proc #t)
	    (sys-sleep 1)
	    (inc! total-sleep)
	    (when (< timeout total-sleep)
	      (when verbose
		(format (current-error-port) "Timeout: ~d\n" timeout)
		(format (current-error-port) "Socket: ~a\n" socket-name)
		(format (current-error-port) "Expression: ~s\n" expression))
	      (process-kill proc)
	      )))
	(process-wait proc #f))
    ;;
    (process-exit-status proc)))

(provide "font-lock/flclient")
