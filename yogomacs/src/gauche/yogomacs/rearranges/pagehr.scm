(define-module yogomacs.rearranges.pagehr
  (export pagehr)
  (use sxml.tree-trans))

(select-module yogomacs.rearranges.pagehr)

(define (pagehr sxml)
  (pre-post-order sxml
		  `((*text* . ,(lambda (tag str) 
				 (if (equal? str "\f")
				     '(hr)
				     str)))
		    (*default* . ,(lambda x x))
		    )))
(provide "yogomacs/rearranges/pagehr")