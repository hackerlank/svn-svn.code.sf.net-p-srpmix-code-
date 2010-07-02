(define-module yogomacs.dests.print-alist
  (export print-alist)
  (use text.html-lite)
  (use www.cgi)
  )
(select-module yogomacs.dests.print-alist)

(define (print-alist path params config title alist)
  (list (cgi-header)
	(html-doctype)
	(html:html
	 (html:head (html:title title))
	 (html:body 
	  (html:dl
	   (map
	    (lambda (e)
	      (list (html:dt (html-escape-string (car e)))
		    (html:dd (html-escape-string (cdr e)))))
	    alist))))))

(provide "yogomacs/dests/print-alist")
