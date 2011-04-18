(define-module yogomacs.util.sxml
  (export get-meta-from-shtml)
  (use util.list)
  (use sxml.sxpath)
  )

(select-module yogomacs.util.sxml)

(define (get-meta-from-shtml shtml var-name)
  ((sxpath `(// html head meta @ ,(lambda (node root vars)
				    (any (lambda (elt)
					   (and-let* ((attrs (cdr elt))
						      (name (car (assq-ref attrs 'name '(#f))))
						      ( (equal? name var-name) )
						      (content (car (assq-ref attrs 'content '(#f)))))
					     content)) node)))) shtml))

(provide "yogomacs/util/sxml")