(define-module yogomacs.path
  (export decompose-path
	  compose-path
	  compose-path*
	  path->head)
  (use file.util))

(select-module yogomacs.path)

(define (decompose-path path-string) 
  (cdr (string-split path-string #\/)))

(define (compose-path path-list)
  (apply build-path (cons "/" path-list)))

(define (compose-path* path-list elt)
   (compose-path (reverse! (cons elt (reverse path-list)))))

(define (path->head path)
  (let1 l (reverse (cdr (reverse path)))
    (if (null? l)
	""
	(apply build-path l))))

(provide "yogomacs/path")
