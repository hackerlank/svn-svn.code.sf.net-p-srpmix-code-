(define-module yogomacs.rearranges.tag-integrates
  (export tag-integrates)
  (use sxml.tree-trans)
  (use srfi-1)
  (use yogomacs.util.sxml))

(select-module yogomacs.rearranges.tag-integrates)

(define (tag-integrates sxml has-tag?)
  (pre-post-order sxml
		  `((head . ,(lambda (tag . rest)
			       (cons tag (reverse 
					  (cons* 
					   `(meta (|@|
						   (name "has-tag?")
						   (content ,(if has-tag?
								 "#t"
								 "#f"))))
					   "	"
					   "\n"
					   (reverse rest))))))
		    ,@no-touch)))

(provide "yogomacs/rearranges/tag-integrates")