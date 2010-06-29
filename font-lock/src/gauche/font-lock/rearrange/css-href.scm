(define-module font-lock.rearrange.css-href
  (export rearrange-css-href)
  (use sxml.tree-trans))
(select-module font-lock.rearrange.css-href)

(define (rearrange-css-href sxml-tree converter)
  (pre-post-order sxml-tree
		  `(
		    (link *preorder* . ,(lambda x x))
		    (css-href . ,(lambda x
			       `(css-href ,css-href)))
		    (*text* . ,(lambda (tag str) str))
		    (*default* . ,(lambda x x))
		    )))

(provide "font-lock/rearrange/css-href")