(define-module yogomacs.handlers.deliver-css
  (export deliver-css-handler)
  (use www.cgi)  
  (use file.util)
  (use yogomacs.access)
  (use yogomacs.css-cache)
  (use srfi-1)
  )

(select-module yogomacs.handlers.deliver-css)

(define (deliver-css-handler path params config)
  (let1 last (last path)
    (let1 real (readable? (css-cache-dir config)
			  last)
      (if real
	  (list (cgi-header :content-type "text/css")
		(call-with-input-file real
		  port->string))
	  (cgi-header :status "404 Not Found")
	  ))))

(provide "yogomacs/handlers/deliver-css")