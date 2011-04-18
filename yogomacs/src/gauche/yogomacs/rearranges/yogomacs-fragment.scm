(define-module yogomacs.rearranges.yogomacs-fragment
  (export yogomacs-fragment)
  (use srfi-1)
  (use sxml.sxpath)
  (use sxml.tree-trans)
  (use yogomacs.shell)
  (use yogomacs.shells.bscm)
  (use yogomacs.shells.ysh)
  (use yogomacs.major-mode)
  (use yogomacs.tag)
  )

(select-module yogomacs.rearranges.yogomacs-fragment)

(define (yogomacs-fragment shtml shell-name)
  (let* ((title ((if-car-sxpath '(// html head title *text*)) shtml))
	 (major-mode (major-mode-from-shtml shtml))
	 (has-tag? (has-tag?-from-shtml shtml))
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
			      (*text* . ,(lambda (tag str) str))
			      (*default* . ,(lambda x x))
			      ))
			   a-text)))
		  (*text* . ,(lambda (tag str) str))
		  (*default* . ,(lambda x x))))))
    `(*TOP* (*PI* xml "version=\\"1.0\\" encoding=\\"UTF-8\\"")
	    ,(cons* 'pre `(|@| (class "contents") (id "contents"))
		    ;;
		    `(span (|@| (id "major-mode")) ,major-mode)
		    `(span (|@| (id "has-tag?"))   ,has-tag?)
		    ;;
		    (cdr frag)))))
  
(provide "yogomacs/rearranges/yogomacs-fragment")
