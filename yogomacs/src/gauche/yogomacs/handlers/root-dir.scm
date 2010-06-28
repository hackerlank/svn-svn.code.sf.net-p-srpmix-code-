(define-module yogomacs.handlers.root-dir
  (export root-dir)
  (use text.html-lite)
  (use www.cgi)  
  ;;
  (use yogomacs.dentries.fs)
  (use yogomacs.dired)
  (use yogomacs.path)
  ;;
  (use yogomacs.render)
  (use yogomacs.css-cache)
  ;;
  (use util.combinations)
  )
(select-module yogomacs.handlers.root-dir)

(define (accept? e)
  (member  e (list
	      "."
	      ".."
	      "package"
	      "sources"
	      "dists")))

(define (root-dir-make-url fs-dentry)
  (cond
   ((equal? "." (dname-of fs-dentry)) "/")
   ((equal? ".." (dname-of fs-dentry)) "/")
   (else (string-append "/" (dname-of fs-dentry)))))

(define (prepare-dired-faces config)
  (for-each
   (lambda (face-style)
     (prepare-css-cache config (car face-style) (cadr face-style) '(dired)))
   (cartesian-product `(,dired-faces
			,dired-styles))))

(define (root-dir path params config)
  (prepare-dired-faces config)
  (list
   (cgi-header)
   (render
    (dired (compose-path path)
	   (read-dentries "/srv/sources"
			  root-dir-make-url
			  #f
			  accept?)
	   "/web/css")
    )))

(provide "yogomacs/handlers/root-dir")