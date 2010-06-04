(define-module flclient
  (export flclient-xhtmlize
	  flclient-cssize)
  (use gauche.process)
  )
(select-module flclient)

(define (flclient-xhtmlize src-file html-file css-dir . rest)
  (let-keywords rest ((emacsclient :emacsclient "emacsclient")
		      (socket-name :socket-name "flserver"))
		(invoke-emacsclient emacsclient
				    socket-name
				    `(flserver-entry 'xhtmlize ,src-file ,html-file ,css-dir))))

(define (flclient-cssize face css-dir requires . rest)
  (let-keywords rest ((emacsclient :emacsclient "emacsclient")
		      (socket-name :socket-name "flserver"))
		(invoke-emacsclient emacsclient
				    socket-name
				    `(flserver-entry 'cssize ',face ,css-dir ',requires))))

;; TODO: Timeout
(define (invoke-emacsclient emacsclient socket-name expression)
  (let1 proc (run-process (list emacsclient
				(format "--socket-name=~a" socket-name)
				"--eval" (format "~s" expression))
			  :wait #t)
    (let1 status (process-exit-status proc)
      (if (eq? status 0) 0 1))))

(provide "flclient")
