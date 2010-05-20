(define-module yogomacs.flserver
  (use gauche.process)
  (use yogomacs.config)
  (export run-flserver))

(select-module yogomacs.flserver)

(define (run-flserver)
  (run-process (list "screen"
		     "-d"
		     "-m"
		     (string-append flserver-prog-dir "/flserver")
		     flserver-prog-dir
		     emacs
		     ) 
	       :wait #f))


(provide "yogomacs/flserver")