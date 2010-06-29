(define-module font-lock.rearrange.css-href
  (export rearrange-css-href)
  (use sxml.tree-trans))
(select-module font-lock.rearrange.css-href)

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
						 (*text* . ,(lambda (tag str) str))
						 (*default* . ,(lambda x x))
						 ))))
		    (*text* . ,(lambda (tag str) str))
		    (*default* . ,(lambda x x))
		    )))

(provide "font-lock/rearrange/css-href")