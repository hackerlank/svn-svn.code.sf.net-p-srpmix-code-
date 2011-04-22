(define-module yogomacs.rearranges.css-href
  (export rearrange-css-href)
  (use sxml.tree-trans)
  (use yogomacs.util.sxml))
(select-module yogomacs.rearranges.css-href)

(define (rearrange-css-href sxml-tree converter)
  (pre-post-order sxml-tree
		  `(
		    (link . ,(lambda x
			       (pre-post-order x
					       `(
						 (href . ,(lambda (tag str)
							    (if (#/.*\.css/ str)
								`(href ,(converter str))
								`(href ,str))
							    ))
						 ,@no-touch
						 ))))
		    ,@no-touch
		    )))

(provide "yogomacs/rearranges/css-href")