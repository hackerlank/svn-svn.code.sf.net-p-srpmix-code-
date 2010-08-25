(define-module yogomacs.dests.subjects
  (export subjects-dest
	  subjects-route
	  subjects-route$
	  )
  (use www.cgi)  
  (use yogomacs.yarn)
  (use file.util)
  (use srfi-19)
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
		(map
		 (lambda (s)
		   (list (car s)
			 :nlink (ref (cdr s) 0)
			 :size  (ref (cdr s) 1)
			 :date  (date->string (time-utc->date (ref (cdr s) 2))
					      "~a ~b ~e ~H:~M:~S ~Y")))
		 (all-subjects params config)))))))

(provide "yogomacs/dests/subjects")