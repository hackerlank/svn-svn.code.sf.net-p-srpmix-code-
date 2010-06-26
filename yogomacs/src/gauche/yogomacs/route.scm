(define-module yogomacs.route
  (export route)
  (use yogomacs.handlers.print-path)
  )
(select-module yogomacs.route)

;; TODO
(define (sanitize-path path) path)
(define (decompose path) path) 

(define (route rtable path params)
  (route0 rtable
	  (sanitize-path path)
	  params))

(define (route0 rtable path params)
  (if (null? rtable)
      (print-path (decompose path) params)		; TODO
      (let ((regex (car (car rtable)))
	    (action (cadr (car rtable))))
	(if (regex path)
	    (action (decompose path) params)
	    (route0 (cdr rtable) path params)))))

(provide "yogomacs/route")