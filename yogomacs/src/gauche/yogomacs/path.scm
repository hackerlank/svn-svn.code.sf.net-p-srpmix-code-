(define-module yogomacs.path
  (export decompose-path
	  compose-path
	  compose-path*
	  path->head
	  parent-of
	  directory-file-name
	  url->href-list
	  make-real-src-path
	  )
  (use file.util)
  (use util.list))

(select-module yogomacs.path)

(define (decompose-path path-string) 
  (cdr (string-split path-string #\/)))

(define (compose-path lpath)
  (apply build-path (cons "/" lpath)))

(define (compose-path* lpath elt)
   (compose-path (reverse! (cons elt (reverse lpath)))))

(define (parent-of path)
  (reverse (cdr (reverse path))))

(define (path->head path)
  (let1 l (parent-of path)
    (if (null? l)
	""
	(apply build-path l))))

(define (directory-file-name dpath)
  (build-path (sys-dirname dpath) (sys-basename dpath)))

(define (url->href-list url shell)
  (let1 splited-list (let loop ((url url)
				(result (list)))
		       (if (equal? "/" url)
			   result
			   (loop  (sys-dirname url)
				  (cons url result))))
    (cons `(a (|@| (href ,(if shell 
			      #`"/,|shell|/"
			      "/"))) "/")
	  (intersperse "/"
		       (map
			(lambda (elt)
			  `(a (|@| (href ,(if shell
					      #`"/,|shell|,|elt|"
					      #`",|elt|"))) 
			      ,(sys-basename elt)))
			splited-list)))))

(define (make-real-src-path config . tail-components)
  (apply build-path (config 'real-sources-dir) tail-components))

(provide "yogomacs/path")
