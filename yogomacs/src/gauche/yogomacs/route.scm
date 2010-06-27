(define-module yogomacs.route
  (export route)
  (use yogomacs.handlers.print-path)
  (use yogomacs.sanitize)
  (use yogomacs.path)
  )
(select-module yogomacs.route)

(define (route rtable path params)
  (route0 rtable
	  (sanitize-path path)
	  params))

(define (route0 rtable path params)
  (if (null? rtable)
      (print-path (decompose-path path) params)		; TODO
      (let ((regex (car (car rtable)))
	    (action (cadr (car rtable))))
	(if (regex path)
	    (action (decompose-path path) params)
	    (route0 (cdr rtable) path params)))))

(provide "yogomacs/route")