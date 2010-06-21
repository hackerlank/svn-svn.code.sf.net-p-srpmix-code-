(define-module font-lock.flclient
  (export flclient-ping
	  flclient-xhtmlize
	  flclient-shtmlize
	  flclient-cssize
	  flclient-shutdown)
  (use gauche.process)
  )
(select-module font-lock.flclient)


(define (flclient-ping . rest)
  (let-keywords rest ((emacsclient :emacsclient "emacsclient")
		      (socket-name :socket-name "flserver")
		      (verbose :verbose #f)
		      (timeout :timeout 1))
		(invoke-emacsclient emacsclient
				    socket-name
				    verbose
				    timeout
				    `(flserver 'ping)
				    )))

(define (flclient-xhtmlize src-file html-file css-dir . rest)
  (let-keywords rest ((emacsclient :emacsclient "emacsclient")
		      (socket-name :socket-name "flserver")
		      (verbose :verbose #f)
		      (timeout :timeout 60))
		(invoke-emacsclient emacsclient
				    socket-name
				    verbose
				    timeout
				    `(flserver 'xhtmlize ,src-file ,html-file ,css-dir)
				    )))

(define (flclient-shtmlize src-file shtml-file css-dir . rest)
  (let-keywords rest ((emacsclient :emacsclient "emacsclient")
		      (socket-name :socket-name "flserver")
		      (verbose :verbose #f)
		      (timeout :timeout 60))
		(invoke-emacsclient emacsclient
				    socket-name
				    verbose
				    timeout
				    `(flserver 'shtmlize ,src-file ,shtml-file ,css-dir)
				    )))

(define (flclient-cssize face css-dir requires . rest)
  (let-keywords rest ((emacsclient :emacsclient "emacsclient")
		      (socket-name :socket-name "flserver")
		      (verbose :verbose #f)
		      (timeout :timeout 10))
		(invoke-emacsclient emacsclient
				    socket-name
				    verbose
				    timeout
				    `(flserver 'cssize ',face ,css-dir ',requires)
				    )))
(define (flclient-shutdown . rest)
  (let-keywords rest ((emacsclient :emacsclient "emacsclient")
		      (socket-name :socket-name "flserver")
		      (verbose :verbose #f)
		      (timeout :timeout 60))
		(invoke-emacsclient emacsclient
				    socket-name
				    verbose
				    timeout
				    `(flserver 'shutdown)
				    )))

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
