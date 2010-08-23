(define-module yogomacs.dests.yarn
  (export yarn-dest
	  yarn-route
	  yarn-route$
	  )
  (use www.cgi)  
  #;(use yogomacs.access)
  #;(use yogomacs.caches.yarn)
  #;(use srfi-1)
  (use file.util)
  (use yogomacs.yarn)
  (use yogomacs.path)
  )

(select-module yogomacs.dests.yarn)

(define yarn-route "/web/yarn")
(define (yarn-route$ elt)
   (build-path yarn-route elt))

(define (yarn-dest path params config)
  (list (cgi-header :content-type "text/x-es")
	(with-output-to-string
	  (pa$ write (cons 'yarn-container
			   (collect-yarns-by-path 
			    (compose-path (cddr path))
			    params
			    config)))
	  )))

(provide "yogomacs/dests/yarn")