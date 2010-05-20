(define-module yogomacs.emacsclient
  (use srfi-1)

  (use gauche.process)
  (use yogomacs.config)
    
  (export run-emacsclient)
  )

(select-module yogomacs.emacsclient)

(define (run-emacsclient socket-path es-script wait?)
  (run-process (list emacsclient
		     (format "--socket-name=~a" socket-path)
		     "--eval" (format "~s" es-script))
	       :wait wait?))

(provide "yogomacs/emacsclient")