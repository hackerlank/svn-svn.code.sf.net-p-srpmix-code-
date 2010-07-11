(define-module yogomacs.compress
   (export with-input-from-compressed-file
	   compress)
   (use gauche.process)
   )

(select-module yogomacs.compress)

(define (with-input-from-compressed-file zfile thunk)
  (with-input-from-process `(xz --stdout ,zfile)
    thunk
    :on-abnormal-exit  :error))

(define (compress file)
  (run-process `(compress ,file) :wait #t))

(provide "yogomacs/compress")
	       