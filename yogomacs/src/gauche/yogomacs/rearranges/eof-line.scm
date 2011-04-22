(define-module yogomacs.rearranges.eof-line
  (export eof-line)
  (use sxml.tree-trans)
  (use srfi-1)
  (use yogomacs.util.sxml))

(select-module yogomacs.rearranges.eof-line)

(define (eof-line sxml-tree)
  (pre-post-order sxml-tree
		  `(
		    (body . ,(lambda (tag attr . rest)
			       (cons* tag attr (if (and (list? attr)
							(not (null? attr))
							(eq? '@ (car attr)))
						   rest
						   (reverse (cons '(hr) (reverse rest)))))))
		    ,@no-touch
		    )))

(provide "yogomacs/rearranges/eof-line")