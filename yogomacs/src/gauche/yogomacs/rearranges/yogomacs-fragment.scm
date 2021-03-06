(define-module yogomacs.rearranges.yogomacs-fragment
  (export yogomacs-fragment)
  (use srfi-1)
  (use sxml.sxpath)
  (use sxml.tree-trans)
  (use yogomacs.shell)
  (use yogomacs.shells.ysh)
  (use yogomacs.tag)
  (use yogomacs.util.sxml)
  (use srfi-13)
  )

(select-module yogomacs.rearranges.yogomacs-fragment)

(define (yogomacs-fragment shtml shell-name)
  (let* ((title ((if-car-sxpath '(// html head title *text*)) shtml))
	 (frag ((if-car-sxpath '(// html body pre)) shtml))
	 (frag (pre-post-order
		frag 
		`(
		  (span . ,(lambda (tag attrs . rest)
			     (or (and-let* (( (list? attrs) )
					    ( (not (null? attrs)) )
					    ( (eq? (car attrs) '@) )
					    (id    (assq 'id (cdr attrs)))
					    ( id )
					    (class (assq 'class (cdr attrs)))
					    ( class )
					    )
				   (cond
				    ((equal? (cadr class) "lfringe")
				     (cons* 'a
					    (cons* '@ '(href "#") (cdr attrs))
					    rest)
				     )
				    ((equal? (cadr class) "rfringe")
				     (cons* 'a
					    (cons* '@ '(href "#") (cdr attrs))
					    rest))
				    (else
				     (cons* tag attrs rest))))
				 (cons* tag attrs rest)
				 )))
		  (a . ,(lambda (tag attr a-text)
			  (list 
			   tag
			   (pre-post-order
			    attr
			    `((href . ,(lambda (tag text) 
					 (list tag
					       (cond
						((#/^#/ text) text)
						((equal? a-text ".") text)
						;; TOOD: THIS SHOULD BE SEPARATED REARRANGE?
						((and (equal? title "/")
						      (equal? a-text ".."))
						 "/"
						 )
						((and-let* ((m (#/^\/(.+)/ text))
							    (entry (m 1))
							    ((member entry (map (cut ref <> 'name)
										(all-shells)))))
						   #t) text)
						((#/^http:.*/ text) text)
						((#/^ftp:.*/ text) text)
						(else (string-append #`"/,|shell-name|" text))))))
			      ,@no-touch
			      ))
			   a-text)))
		  ,@no-touch
		  ))))
    `(*TOP* (*PI* xml "version=\\"1.0\\" encoding=\\"UTF-8\\"")
	    ,(cons* 'pre `(|@| (class "contents") (id "contents"))
		    (cdr frag)))))
  
(provide "yogomacs/rearranges/yogomacs-fragment")
