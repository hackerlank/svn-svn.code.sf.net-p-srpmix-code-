(define-module yogomacs.rearranges.yogomacs-fragment
  (export yogomacs-fragment)
  (use srfi-1)
  (use sxml.sxpath)
  (use sxml.tree-trans)
  (use yogomacs.shell)
  (use yogomacs.shells.bscm)
  (use yogomacs.shells.ysh)
  )

(select-module yogomacs.rearranges.yogomacs-fragment)

(define (yogomacs-fragment shtml shell-name)
  (let* ((frag ((if-car-sxpath '(// html body pre)) shtml))
	 (frag (pre-post-order frag 
			       `((href . ,(lambda (tag text) 
					    (list tag
						  (cond
						   ((#/^#/ text) text)
						   ((and-let* ((m (#/^\/(.+)/ text))
							       (entry (m 1))
							       ((member entry (map (cut ref <> 'name)
										  (all-shells)))))
						      #t) text)
						   ((#/^http:.*/ text) text)
						   ((#/^ftp:.*/ text) text)
						   (else (string-append #`"/,|shell-name|" text))))))
				 (*text* . ,(lambda (tag str) str))
				 (*default* . ,(lambda x x))))))
    `(*TOP* (*PI* xml "version=\\"1.0\\" encoding=\\"UTF-8\\"")
	    ,(cons* 'pre `(|@| (class "contents") (id "contents"))
		    (cdr frag)))))
  
(provide "yogomacs/rearranges/yogomacs-fragment")
