(define-module yogomacs.rearranges.css-integrates
  (export css-integrates)
  (use sxml.tree-trans)
  (use yogomacs.util.sxml))
(select-module yogomacs.rearranges.css-integrates)

(define (css-integrates sxml-tree integrated-links purge?)
  (pre-post-order sxml-tree
		  `(
		    (head . ,(lambda (tag . x)
			       `(,tag
				 ,@(fold-right
				    (lambda (elt result)
				      (if (and-let* (( (list? elt) )
						     ( (eq? (car elt) 'link) )
						     (|@| (ref elt 1))
						     ( (eq? (car |@|) '|@|) )
						     (|@| (cdr |@|))
						     (rel (assq 'rel |@|))
						     ( (list? rel) )
						     ( (equal? (ref rel 1) "stylesheet") )
						     (type (assq 'type |@|))
						     ( (list? type) )
						     ( (equal? (ref type 1) "text/css") )
						     (href (assq 'href |@|))
						     ( (list? href) )
						     (title (assq 'title |@|))
						     ( (list? title) )
						     ( (or (equal? (ref title 1) "Default") 
							   (equal? (ref title 1) "Invert")) )
						     ( (purge? (ref href 1)) ))
					    #t)
					  result
					  (cons elt result)))
				    (list)
				    x)
				 ,@integrated-links
				 )))
		    ,@no-touch
		    )))

(provide "yogomacs/rearranges/css-integrates")