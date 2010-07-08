(define-module yogomacs.renderer
  (export face->css-route
	  face->css-file
	  <renderer-error>
	  timeout
	  not-found
	  internal-error))
(select-module yogomacs.renderer)

(define-condition-type <renderer-error> <error>
   #f
  (status)
  (log)
  )

(define (face->css-route face style css-prefix)
  (format "~a/~a" css-prefix (face->css-file face style)))
(define (face->css-file face style)
  (format "~a--~a.css" face style))

(define (base-error status)
   (lambda (msg log)
      (error <renderer-error>
	  :status status
	  :log (format "~a: ~a" msg log)
	  msg)))

(define timeout
   (base-error "504 Gateway Timeout"))
(define not-found
   (base-error "403 Not Found"))
(define internal-error
   (base-error "500 Internal Error"))

(provide "yogomacs/renderer")