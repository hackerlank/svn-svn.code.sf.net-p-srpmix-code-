(define-module yogomacs.renderers.outlang
  (export outlang)
  (use outlang.outlang)
  (use yogomacs.access)
  (use yogomacs.error)
  )
(select-module yogomacs.renderers.outlang)

(define (outlang src-path config)
  (if (readable? src-path)
      (let1 shtml (with-module outlang.outlang
		    (outlang src-path :embed-links #f))
	(or shtml
	    (internal-error "Cannot handle the source file"
			    src-path)))
      (not-found "File not found"
		 src-path)))
(provide "yogomacs/renderers/outlang")