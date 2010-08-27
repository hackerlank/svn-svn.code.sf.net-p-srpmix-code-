(define-module yogomacs.rearranges.checkout
  (export checkout)
  (use sxml.sxpath)
  (use sxml.tree-trans)
  (use yogomacs.access)
  )

(select-module yogomacs.rearranges.checkout)

(define (checkout shtml config)
  (let1 title ((if-car-sxpath '(// html head title *text*)) shtml)
    (pre-post-order
     shtml
     `((a . ,(lambda (tag attr a-text)
	       (list 
		tag
		(pre-post-order
		 attr
		 `((href . ,(lambda (tag text) 
			      (list tag
				    (cond
				     ((and (equal? a-text ".")
					   (archivable?  (string-append
							  (config 'real-sources-dir)
							  title)
							 config))
				      #`"/commands/checkout,|title|")
				     (else text)))))
		   (*text* . ,(lambda (tag str) str))
		   (*default* . ,(lambda x x))
		   ))
		a-text)))
       (*text* . ,(lambda (tag str) str))
       (*default* . ,(lambda x x))))))

(provide "yogomacs/rearranges/checkout")