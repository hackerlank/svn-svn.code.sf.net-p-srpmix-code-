(define-module yogomacs.overlay
  (export overlay->route
	  overlay-handlers
	  define-overlay-handler)
  )

(select-module yogomacs.overlay)

(define overlay-handlers (make-hash-table 'eq?))
(define-macro (define-overlay-handler name proc)
  `(hash-table-put! overlay-handlers (quote ,name) ,proc))

(define (overlay->route overlay)
  (and-let* (( (list? overlay) )
	     ( (not (null? overlay)) )
	     ( (symbol? (car overlay)) )
	     (oname (car overlay) )
	     (handler (ref overlay-handlers oname #f))
	     (args  (cdr overlay)))
    (handler oname args)
    ))

(provide "yogomacs/overlay")