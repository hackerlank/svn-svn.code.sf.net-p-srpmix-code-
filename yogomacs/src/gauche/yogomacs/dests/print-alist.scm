(define-module yogomacs.dests.print-alist
  (export print-alist
	  print-alist0)
  (use text.html-lite)
  (use www.cgi)
  )
(select-module yogomacs.dests.print-alist)

(define (print-alist0 path params config title alist)
  (list (html-doctype)
	(html:html
	 (html:head (html:title title))
	 (html:body 
	  (html:dl
	   (map
	    (lambda (e)
	      (list (html:dt (html-escape-string (car e)))
		    (html:dd (html-escape-string (cdr e)))))
	    alist))))))

(define (print-alist path params config title alist)
   (cons (cgi-header)
	 (print-alist0 path path config title alist)))

(provide "yogomacs/dests/print-alist")
