(define-module yogomacs.util.fs
  (export readlink-safe)
  )

(select-module yogomacs.util.fs)
		   
(define (readlink-safe path)
  (guard (e (else #f)) 
	 (sys-readlink path)))

(provide "yogomacs/util/fs")