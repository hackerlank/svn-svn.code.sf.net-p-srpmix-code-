(define-module yogomacs.rearranges.normalize-major-mode
  (export normalize-major-mode)
  (use yogomacs.major-mode)
  (use sxml.tree-trans)
  (use srfi-1)
  )
(select-module yogomacs.rearranges.normalize-major-mode)

(define (normalize-major-mode sxml-tree)
  (pre-post-order sxml-tree
		  `(
		    (meta (
			   (|@| . ,(lambda (at name content . rest)
				     (if (and (list? name)
					      (eq? (car name) 'name)
					      (equal? (cadr name) "major-mode"))
					 (let1 major-mode (cadr content)
					   (cons* at name (list 'content
								(with-module yogomacs.major-mode
								  (normalize-major-mode major-mode)))
						  rest
						  ))
					 (cons* at name content rest)
					 )))
			   (*text* . ,(lambda (tag str) str))
			   (*default* . ,(lambda x x))
			   ) . ,(lambda x x))
		    (*text* . ,(lambda (tag str) str))
		    (*default* . ,(lambda x x))
		    )))

(provide "yogomacs/rearranges/normalize-major-mode")