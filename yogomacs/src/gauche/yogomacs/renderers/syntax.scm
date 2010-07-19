(define-module yogomacs.renderers.syntax
  (export syntax)
  (use syntax.syntax)
  (use yogomacs.access)
  (use yogomacs.error)
  )
(select-module yogomacs.renderers.syntax)

(define (syntax src-path config)
  (if (readable? src-path)
      (let1 shtml (with-module syntax.syntax
		    (syntax src-path))
	(or shtml
	    (internal-error "Cannot handle the source file"
			    src-path)))
      (not-found "File not found"
		 src-path)))
(provide "yogomacs/renderers/syntax")