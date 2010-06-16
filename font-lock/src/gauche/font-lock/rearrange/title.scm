(define-module font-lock.rearrange.title
  (export rearrange-title)
  (use sxml.tree-trans))
(select-module font-lock.rearrange.title)

(define (rearrange-title sxml-tree title)
  (pre-post-order sxml-tree
		  `(
		    (link *preorder* . ,(lambda x x))
		    (title . ,(lambda x
			       `(title ,title)))
		    (*text* . ,(lambda (tag str) str))
		    (*default* . ,(lambda x x))
		    )))

(provide "font-lock/rearrange/title")