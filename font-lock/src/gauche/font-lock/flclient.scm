(define-module font-lock.flclient
  (export flclient-xhtmlize
	  flclient-shtmlize
	  flclient-cssize
	  flclient-shutdown)
  (use gauche.process)
  )
(select-module font-lock.flclient)

(define (flclient-xhtmlize src-file html-file css-dir . rest)
  (let-keywords rest ((emacsclient :emacsclient "emacsclient")
		      (socket-name :socket-name "flserver"))
		(invoke-emacsclient emacsclient
				    socket-name
				    `(flserver 'xhtmlize ,src-file ,html-file ,css-dir))))

(define (flclient-shtmlize src-file shtml-file css-dir . rest)
  (let-keywords rest ((emacsclient :emacsclient "emacsclient")
		      (socket-name :socket-name "flserver"))
		(invoke-emacsclient emacsclient
				    socket-name
				    `(flserver 'shtmlize ,src-file ,shtml-file ,css-dir))))

(define (flclient-cssize face css-dir requires . rest)
  (let-keywords rest ((emacsclient :emacsclient "emacsclient")
		      (socket-name :socket-name "flserver"))
		(invoke-emacsclient emacsclient
				    socket-name
				    `(flserver 'cssize ',face ,css-dir ',requires))))
(define (flclient-shutdown . rest)
  (let-keywords rest ((emacsclient :emacsclient "emacsclient")
		      (socket-name :socket-name "flserver"))
		(invoke-emacsclient emacsclient
				    socket-name
				    `(flserver 'shutdown))))




;; TODO: Timeout
(define (invoke-emacsclient emacsclient socket-name expression)
  (let1 proc (run-process (list emacsclient
				(format "--socket-name=~a" socket-name)
				"--eval" (format "~s" expression))
			  :wait #t)
    (let1 status (process-exit-status proc)
      (if (eq? status 0) 0 1))))

(provide "font-lock/flclient")
