(define-module yogomacs.path
  (export decompose-path
	  compose-path
	  compose-path*
	  path->head
	  parent-of
	  directory-file-name
	  )
  (use file.util))

(select-module yogomacs.path)

(define (decompose-path path-string) 
  (cdr (string-split path-string #\/)))

(define (compose-path path-list)
  (apply build-path (cons "/" path-list)))

(define (compose-path* path-list elt)
   (compose-path (reverse! (cons elt (reverse path-list)))))

(define (parent-of path)
  (reverse (cdr (reverse path))))

(define (path->head path)
  (let1 l (parent-of path)
    (if (null? l)
	""
	(apply build-path l))))

(define (directory-file-name dpath)
  (build-path (sys-dirname dpath) (sys-basename dpath)))

(provide "yogomacs/path")
