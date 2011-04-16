(define-module yogomacs.rearranges.tag-integrates
  (export tag-integrates)
  (use sxml.tree-trans)
  (use srfi-1))

(select-module yogomacs.rearranges.tag-integrates)

(define (tag-integrates sxml has-tag?)
  (pre-post-order sxml
		  `((head . ,(lambda (tag . rest)
			       (cons tag (reverse 
					  (cons* 
					   `(meta (|@|
						   (name "has-tag?")
						   (content ,(if has-tag?
								 "yes"
								 "no"))))
					   "	"
					   "\n"
					   (reverse rest))))))
		    (*text* . ,(lambda (tag str) str))
		    (*default* . ,(lambda x x)))))

(provide "yogomacs/rearranges/tag-integrates")