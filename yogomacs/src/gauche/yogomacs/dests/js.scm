(define-module yogomacs.dests.js
  (export js-dest
	  js-route
	  js-route$)
  (use www.cgi)  
  (use yogomacs.access)
  (use yogomacs.caches.js)
  (use srfi-1)
  (use file.util)
  )

(select-module yogomacs.dests.js)

(define js-route "/web/js")
(define (js-route$ elt)
   (build-path js-route elt))
(define (js-dest path params config)
   (let1 last (last path)
	 (let1 real (readable? (js-cache-dir config) last)
	       (if real
		   (list (cgi-header :content-type "text/javascript")
			 (call-with-input-file real
			    port->string))
		   (cgi-header :status "404 Not Found")
		   ))))

(provide "yogomacs/dests/js")