(define-module yogomacs.handlers.print-path
  (export print-path)
  (use text.html-lite)
  (use www.cgi)  
  )
(select-module yogomacs.handlers.print-path)

(define (print-path path params)
  (list
   (cgi-header)
   (html-doctype)
   (html:html
    (html:head (html:title "print-path"))
    (html:body path))))

(provide "yogomacs/handlers/print-path")