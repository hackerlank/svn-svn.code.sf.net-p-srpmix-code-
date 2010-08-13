(define-module yogomacs.rearranges.title
  (export rearranges-title)
  (use sxml.tree-trans))
(select-module yogomacs.rearranges.title)

(define (rearranges-title sxml-tree title)
  (pre-post-order sxml-tree
		  `(
		    (link *preorder* . ,(lambda x x))
		    (title . ,(lambda x
			       `(title ,title)))
		    (*text* . ,(lambda (tag str) str))
		    (*default* . ,(lambda x x))
		    )))

(provide "yogomacs/rearranges/title")