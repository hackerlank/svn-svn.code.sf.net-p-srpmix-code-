(define-module yogomacs.main
  (use text.html-lite)
  (use www.cgi)
  (export yogomacs-main))

(select-module yogomacs.main)

(define (yogomacs-main params)
  
  (list
   (cgi-header)
   (html-doctype)
   (html:body "XXX")))

(provide "yogomacs/main")