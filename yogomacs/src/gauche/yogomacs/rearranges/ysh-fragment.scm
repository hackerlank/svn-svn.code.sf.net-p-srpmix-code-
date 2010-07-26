(define-module yogomacs.rearranges.ysh-fragment
  (export ysh-fragment)
  (use srfi-1)
  (use sxml.sxpath)
  (use sxml.tree-trans))

(select-module yogomacs.rearranges.ysh-fragment)

(define (ysh-fragment shtml)
  (let* ((frag ((if-car-sxpath '(// html body pre)) shtml))
	 (frag (pre-post-order frag 
			       `((href . ,(lambda (tag text) 
					    (list tag
						  (if (#/^#/ text)
						      text
						      (string-append "/ysh" text)))))
				 (*text* . ,(lambda (tag str) str))
				 (*default* . ,(lambda x x))))))
    `(*TOP* (*PI* xml "version=\\"1.0\\" encoding=\\"UTF-8\\"")
	    ,(cons* 'pre `(|@| (class "buffer") (id "buffer"))
		    (cdr frag)))))
  
(provide "yogomacs/rearranges/ysh-fragment")
