(define-module yogomacs.util.sxml
  (export get-meta-from-shtml
	  no-touch)
  (use util.list)
  (use sxml.sxpath)
  )

(select-module yogomacs.util.sxml)

(define (get-meta-from-shtml shtml var-name)
  (read ((sxpath `(// html head meta |@| ,(lambda (node root vars)
					    (any (lambda (elt)
						   (and-let* ((attrs (cdr elt))
							      (name (car (assq-ref attrs 'name '(#f))))
							      ( (equal? name var-name) )
							      (content (car (assq-ref attrs 'content '(#f)))))
						     content)) node)))) shtml)))

(define no-touch `((*text* . ,(lambda (tag str) str))
		   (*default* . ,(lambda x x))))

(provide "yogomacs/util/sxml")
