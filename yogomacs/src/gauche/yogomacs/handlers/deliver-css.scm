(define-module yogomacs.handlers.deliver-css
  (export deliver-css)
  (use www.cgi)  
  (use file.util)
  )

(select-module yogomacs.handlers.deliver-css)
(define (deliver-css path params)
  ;; TODO: last
  (let1 last (sys-basename path)
    (let1 real (directory-list "/var/lib/yogomacs/css_cache"
			       :add-path?
			       :children?
			       ;; TODO: Readable?
			       :filter (cute equal? last <>))
      (if (null? real)
	  (cgi-header :status "404 Not Found")
	  (list (cgi-header :content-type "text/css")
		(call-with-input-file (car real)
		  port->string))))))

(provide "yogomacs/handlers/deliver-css")