(define-module yogomacs.rearranges.inject-environment
  (export inject-environment)
  (use yogomacs.util.sxml)
  (use util.list)
  (use sxml.tree-trans)
  (use srfi-1))

(select-module yogomacs.rearranges.inject-environment)

(define (inject-environment shtml dont-use-meta kv-list)
  (if dont-use-meta
      (apply install-pseudo-meta shtml kv-list)
      (apply install-meta shtml kv-list)
      ))

(define (install-pseudo-meta shtml . kv-list)
  (define (extend kv-list rest)
    (fold-right (lambda (elt kdr)
		  (cons `(span (|@|
				(id ,(string-append "E:" (keyword->string (car elt))))
				(class "environment")
				(style "display:none;")
				)
			       ,(write-to-string (cadr elt))) 
			kdr))
		rest
		(slices kv-list 2)))
  (pre-post-order shtml
		  `((pre . ,(lambda (tag . rest)
			      (or (and-let* (( (list? rest) )
					     ( (not (null? rest)) ))
				    (cons tag (extend kv-list rest)))
				  (cons tag rest))
			      ))
		    ,@no-touch)))

(provide "yogomacs/rearranges/inject-environment")