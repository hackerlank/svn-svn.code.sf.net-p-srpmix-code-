(define-module yogomacs.dests.debug
  (export print-path
	  print-metavariables
	  print-config
	  print-echo
	  )
  (use www.cgi)  
  (use text.html-lite)
  (use yogomacs.path)
  (use yogomacs.dests.print-alist)
  )

(select-module yogomacs.dests.debug)

(define (print-echo path params config msg)
  (list
   (cgi-header)
   (html-doctype)
   (html:html
    (html:head (html:title (compose-path path)))
    (html:body msg))))

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

(provide "yogomacs/dests/debug")