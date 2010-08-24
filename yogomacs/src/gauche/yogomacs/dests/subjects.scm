(define-module yogomacs.dests.subjects
  (export subjects-dest
	  subjects-route
	  subjects-route$
	  )
  (use www.cgi)  
  (use yogomacs.yarn)
  (use file.util)
  )

(select-module yogomacs.dests.subjects)

(define subjects-route "/web/subjects")
(define (subjects-route$ elt)
   (build-path subjects-route elt))

(define (subjects-dest path params config)
  (list (cgi-header :content-type "text/x-es")
	(with-output-to-string
	  (pa$ write 
	       (list
		'yarn-subjects
		(all-subjects params config)))
	  )))

(provide "yogomacs/dests/subjects")