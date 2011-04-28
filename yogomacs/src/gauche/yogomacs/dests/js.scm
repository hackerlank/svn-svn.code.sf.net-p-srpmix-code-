(define-module yogomacs.dests.js
  (export js-dest
	  js-route
	  js-route$)
  (use www.cgi)  
  (use yogomacs.access)
  (use yogomacs.storages.js)
  (use srfi-1)
  (use file.util)
  (use yogomacs.config)
  )

(select-module yogomacs.dests.js)

(define js-route "/web/js")
(define (js-route$ elt)
   (build-path js-route elt))
(define (js-dest path params config)
  (define (answer file)
    (list (cgi-header :content-type "text/javascript")
	  (call-with-input-file file
	    port->string)))
   (let1 last (last path)
     (cond
      ((readable? (js-cache-dir config) last) => answer)
      ((and (#/yogomacs-[0-9.]+-[0-9.]+\.js/ last)
	    (readable? (js-cache-dir config) 
		       #`"yogomacs-,(version)-,(release).js")) => answer)
      (else
       (cgi-header :status "404 Not Found")))))

(provide "yogomacs/dests/js")