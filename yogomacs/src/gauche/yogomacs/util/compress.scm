(define-module yogomacs.util.compress
   (export with-input-from-compressed-file
	   compress)
   (use gauche.process)
   )

(select-module yogomacs.util.compress)

(define (with-input-from-compressed-file zfile thunk)
  (with-input-from-process `(xz --uncompress --stdout ,zfile)
    thunk
    :on-abnormal-exit  :error))

(define (compress file)
  (run-process `(xz --compress ,file) :wait #t))

(provide "yogomacs/util/compress")
	       