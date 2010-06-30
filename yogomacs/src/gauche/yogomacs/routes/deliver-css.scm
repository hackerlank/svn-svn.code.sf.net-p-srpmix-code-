(define-module yogomacs.dests.deliver-css
  (export deliver-css-dest)
  (use www.cgi)  
  (use file.util)
  (use yogomacs.access)
  (use yogomacs.css-cache)
  (use srfi-1)
  )

(select-module yogomacs.dests.deliver-css)

(define (deliver-css-dest path params config)
  (let1 last (last path)
    (let1 real (readable? (css-cache-dir config)
			  last)
      (if real
	  (list (cgi-header :content-type "text/css")
		(call-with-input-file real
		  port->string))
	  (cgi-header :status "404 Not Found")
	  ))))

(provide "yogomacs/dests/deliver-css")