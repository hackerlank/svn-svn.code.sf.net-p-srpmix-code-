(define-module yogomacs.rearranges.title
  (export rearranges-title)
  (use sxml.tree-trans)
  (use yogomacs.util.sxml))
(select-module yogomacs.rearranges.title)

(define (rearranges-title sxml-tree title)
  (pre-post-order sxml-tree
		  `(
		    (link *preorder* . ,(lambda x x))
		    (title . ,(lambda x
			       `(title ,title)))
		    ,@no-touch
		    )))

(provide "yogomacs/rearranges/title")