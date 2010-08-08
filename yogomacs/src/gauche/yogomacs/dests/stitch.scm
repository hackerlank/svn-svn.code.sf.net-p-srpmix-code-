(define-module yogomacs.dests.stitch
  (export stitch-dest
	  stitch-route
	  stitch-route$)
  (use www.cgi)  
  #;(use yogomacs.access)
  #;(use yogomacs.caches.stitch)
  #;(use srfi-1)
  (use file.util)
  )

(select-module yogomacs.dests.stitch)

(define stitch-route "/web/stitch")
(define (stitch-route$ elt)
   (build-path stitch-route elt))
(define (stitch-dest path params config)
  (list (cgi-header :content-type "text/x-es")
	(with-output-to-string
	  (pa$ write path))))

(provide "yogomacs/dests/stitch")