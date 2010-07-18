(define-module yogomacs.error
  (export error-handler
	  <yogomacs-error>
	  timeout
	  not-found
	  internal-error)
  (use www.cgi)  
  )
(select-module yogomacs.error)

(define-condition-type <yogomacs-error> <error>
   #f
  (status)
  (log)
  )


(define (log msg)
  (print msg (current-error-port)))

(define (error-handler e)
  (cond
   ((condition-has-type? e <yogomacs-error>)
    (log (condition-ref e 'log))
    (list
     (cgi-header :status (condition-ref e 'status))
     #;(print-echo0 path path config (condition-ref e 'message))))
   ((condition-has-type? e <error>)
    (list
     (cgi-header :status "502 Bad Gateway")
     #;(print-echo0 path path config (condition-ref e 'message))))
   (else
    (list
     (cgi-header :status "500 Internal Server Error")))))

(define (base-error status)
   (lambda (msg log)
      (error <yogomacs-error>
	  :status status
	  :log (format "~a: ~a" msg log)
	  msg)))

(define timeout
   (base-error "504 Gateway Timeout"))
(define not-found
   (base-error "403 Not Found"))
(define internal-error
   (base-error "500 Internal Error"))


(provide "yogomacs/error")