(define-module yogomacs.handlers.debug
  (export print-path
	  print-metavariables
	  print-config
	  )
  (use www.cgi)  
  (use text.html-lite)
  (use yogomacs.path)
  (use yogomacs.handlers.print-alist)
  )

(select-module yogomacs.handlers.debug)

(define (print-path path params config)
  (list
   (cgi-header)
   (html-doctype)
   (html:html
    (html:head (html:title "Path"))
    (html:body (compose-path path)))))

(define print-metavariables 
  (cute print-alist <> <> <> "Metavariables" (sys-environ->alist)))

(define (print-config path params config)
  (print-alist path params config "Config" config))

(provide "yogomacs/handlers/debug")