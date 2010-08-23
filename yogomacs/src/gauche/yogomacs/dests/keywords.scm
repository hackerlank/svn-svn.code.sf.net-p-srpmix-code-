(define-module yogomacs.dests.keywords
  (export keywords-dest
	  keywords-route
	  keywords-route$
	  )
  (use www.cgi)  
  (use yogomacs.yarn)
  (use file.util)
  )

(select-module yogomacs.dests.keywords)

(define keywords-route "/web/keywords")
(define (keywords-route$ elt)
   (build-path keywords-route elt))

(define (keywords-dest path params config)
  (list (cgi-header :content-type "text/x-es")
	(with-output-to-string
	  (pa$ write 
	       (list
		'yarn-keywords
		(all-keywords params config)))
	  )))

(provide "yogomacs/dests/keywords")