(define-module yogomacs.route
  (export route)
  (use yogomacs.dests.debug)
  (use yogomacs.sanitize)
  (use yogomacs.path)
  )
(select-module yogomacs.route)

(define (route rtable path params config)
  (route0 rtable
	  ;; TODO check ((sanitize-path path) == path) => redirect
	  (sanitize-path path)
	  params
	  config))

(define (route0 rtable path params config)
  (if (null? rtable)
      (print-path (decompose-path path) params config)		; TODO
      (let ((regex (car (car rtable)))
	    (action (cadr (car rtable))))
	(if (regex path)
	    (action (decompose-path path) params config)
	    (route0 (cdr rtable) path params config)))))

(provide "yogomacs/route")