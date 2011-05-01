(define-module yogomacs.dests.css
  (export css-dest
	  css-route
	  css-route$)
  (use www.cgi)  
  (use yogomacs.access)
  (use yogomacs.storages.css)
  (use yogomacs.face)
  (use srfi-1)
  (use file.util)
  )

(select-module yogomacs.dests.css)

(define css-route "/web/css")
(define (css-route$ elt)
   (build-path css-route elt))

(define (css-dest path params config)
  (let1 last (last path)
    ;; TODO: If LAST is available in CSS-CACHE-DIR, 
    ;;       don't set "DONT-CACHE" attribute to the reply.
    (let1 real (or (readable? (css-cache-dir config) last)
		   (if-let1 m (css-regexp last)
			    (readable? (css-cache-dir config) #`",(m 1)--,(m 2)")
			    #f))
      (if real
	  (let1 css (call-with-input-css-file real port->string config)
	    (if css
		(list (cgi-header :content-type "text/css")
		      css)
		(cgi-header :status "404 Not Found")
		))
	  (cgi-header :status "404 Not Found")
	  ))))

(define css-regexp #/(.*)-(?:[0-9]+)\.(?:[0-9]+)\.(?:[0-9]+)-(?:[0-9]+)--((?:Default|Invert)\.css)/ );|

(provide "yogomacs/dests/css")