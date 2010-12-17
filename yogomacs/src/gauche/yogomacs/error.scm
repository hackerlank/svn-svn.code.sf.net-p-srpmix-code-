(define-module yogomacs.error
  (export error-handler
	  <yogomacs-error>
	  timeout
	  not-found
	  forbidden
	  bad-request
	  internal-error
	  method-not-allowed)
  (use www.cgi)  
  (use text.html-lite)
  
  )
(select-module yogomacs.error)

(define-condition-type <yogomacs-error> <error>
   #f
  (status)
  (log)
  )

(define (log msg)
  (with-output-to-port (current-error-port)
    (pa$ print msg)))

(define (error-handler raw-config e)
  (cond
   ((condition-has-type? e <yogomacs-error>)
    ;; TODO: This permits log overflow attacks.
    (log (condition-ref e 'log)))
   ((condition-has-type? e <message-condition>)
    (log (condition-ref e 'message))))
  e)

(define (base-error status)
   (lambda (msg log)
      (error <yogomacs-error>
	  :status status
	  :log (format "~a: ~a" msg log)
	  msg)))

(define timeout
   (base-error "504 Gateway Timeout"))
(define not-found
   (base-error "404 Not Found"))
(define forbidden
  (base-error "403 Forbidden"))
(define internal-error
   (base-error "500 Internal Error"))
(define bad-request
  (base-error "400 Bad Request"))
(define method-not-allowed
  (base-error "405 Method Not Allowed"))
(provide "yogomacs/error")