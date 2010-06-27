(define-module yogomacs.path
  (export decompose-path
	  compose-path)
  (use file.util))

(select-module yogomacs.path)


(define (decompose-path path-string) 
  (cdr (string-split path-string #\/)))

(define (compose-path path-list)
  (apply build-path (cons "/" path-list)))


(provide "yogomacs/path")
