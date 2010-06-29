(define-module yogomacs.handlers.root-dir
  (export root-dir)
  (use www.cgi)  
  ;;
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)
  (use yogomacs.dired)
  (use yogomacs.path)
  (use yogomacs.handlers.dir)
  ;;
  (use yogomacs.render)
  )
(select-module yogomacs.handlers.root-dir)

(define root-dir-spec
  `(("." "/")
    (".." "/")
    (#/^(?:package|sources|dists)$/ ,(lambda (fs-dentry) 
				       (string-append "/"
						      (dname-of fs-dentry))))))

(define (root-dir path params config)
  (prepare-dired-faces config)
  (list
   (cgi-header)
   (render
    (dired (compose-path path)
	   (read-dentries+ "/srv/sources" root-dir-spec)
	   "/web/css")
    )))

(provide "yogomacs/handlers/root-dir")