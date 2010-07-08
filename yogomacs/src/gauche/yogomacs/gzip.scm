(define-module yogomacs.gzip
   (export with-input-from-gzip-file
	   gzip)
   (use gauche.process)
   )

(select-module yogomacs.gzip)

(define (with-input-from-gzip-file gzip-file thunk)

  (with-input-from-process `(gunzip --stdout ,gzip-file)
    thunk
    :on-abnormal-exit  :error))

(define (gzip file)
  (run-process `(gzip ,file) :wait #t))

(provide "yogomacs/gzip")
	       