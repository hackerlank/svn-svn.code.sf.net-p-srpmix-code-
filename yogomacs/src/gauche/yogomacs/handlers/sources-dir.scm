(define-module yogomacs.handlers.sources-dir
  (export sources-dir)
  (use text.html-lite)
  (use www.cgi)  
  ;;
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)
  (use yogomacs.dired)
  (use yogomacs.path)
  (use yogomacs.handlers.dir)
  ;;
  (use yogomacs.render)
  ;;
  )
(select-module yogomacs.handlers.sources-dir)

(define sources-dir-spec
  `(("." "/sources")
    (".." "/")
    (#/.*/ ,(lambda (fs-dentry) 
	      (string-append "/sources/" 
			     (dname-of fs-dentry))))))


(define (sources-dir path params config)
  (prepare-dired-faces config)
  (list
   (cgi-header)
   (render
    (dired (compose-path path)
	   (read-dentries+ "/srv/sources/sources" sources-dir-spec)
	   ;; THIS IS CONSTANT
	   "/web/css")
    )))

(provide "yogomacs/handlers/sources-dir")