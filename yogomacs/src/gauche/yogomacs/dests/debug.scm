(define-module yogomacs.dests.debug
  (export print-path
	  print-metavariables
	  print-config
	  print-echo
	  print-path0
	  print-metavariables0
	  print-config0
	  print-echo0
	  )
  (use www.cgi)  
  (use text.html-lite)
  (use yogomacs.path)
  (use yogomacs.dests.print-alist)
  )

(select-module yogomacs.dests.debug)

(define-macro (define-with-cgi-header +cgi-header base)
   `(define (,+cgi-header . rest)
       (cons (cgi-header)
	     (apply ,base rest))))
(define (print-echo0 path params config msg)
  (list
   (html-doctype)
   (html:html
    (html:head (html:title (compose-path path)))
    (html:body (html-escape-string msg)))))
(define-with-cgi-header print-echo print-echo0)

(define (print-path0 path params config)
  (list
   (html-doctype)
   (html:html
    (html:head (html:title "Path"))
    (html:body (html-escape-string (compose-path path))))))
(define-with-cgi-header print-path print-path0)

;; (cgi-metavariables)
(define print-metavariables0
  (cute print-alist <> <> <> "Metavariables" (sys-environ->alist)))
(define-with-cgi-header print-metavariables print-metavariables0)

(define (print-config0 path params config)
  (print-alist path params config "Config" config))
(define-with-cgi-header print-config print-config0)

(provide "yogomacs/dests/debug")