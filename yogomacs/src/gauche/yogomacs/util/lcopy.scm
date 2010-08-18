(define-module yogomacs.util.lcopy
  (export lcopy-dir->checkout-cmdline
	  lcopy-dir->no-update?)
  (use gauche.process)
  (use file.util)
  )

(select-module yogomacs.util.lcopy)

(define (lcopy-file->checkout-cmdline lcopy-file)
  (guard (e (else #f))
    (call-with-input-process
	`(lcopy-checkout 
	  --just-print-cmdline
	  ,lcopy-file)
      read-line
      :on-abnormal-exit :error)))
    
(define (lcopy-dir->checkout-cmdline path)
  (let1 lcopy-file (build-path path "checkout.lcopy")
    (if (file-is-readable? lcopy-file)
	(lcopy-file->checkout-cmdline lcopy-file)
	#f)))

(define (lcopy-dir->no-update? path)
  (guard (e (else #f))
    (let1 proc (run-process `(lcopy-update
			      --no-update-p
			      ,path)
			    :wait #t)
      (eq? (process-exit-status proc) 0))))

(provide "yogomacs/util/lcopy")
