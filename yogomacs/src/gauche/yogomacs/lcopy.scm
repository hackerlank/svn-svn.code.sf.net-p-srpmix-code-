(define-module yogomacs.lcopy
  (export lcopy-dir->checkout-cmdline)
  (use gauche.process)
  (use file.util)
  )

(select-module yogomacs.lcopy)

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


(provide "yogomacs/lcopy")