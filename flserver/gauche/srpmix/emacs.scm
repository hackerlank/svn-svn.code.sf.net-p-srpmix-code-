(define-module srpmix.emacs
  (use srfi-1)

  (use gauche.process)
  (use srpmix.config)
    
  (export run-emacs)
  )

(select-module srpmix.emacs)

(define (run-emacs socket-path es-script wait?)
  (run-process (list emacsclient
		     (format "--socket-name=~a" socket-path)
		     "--eval" (format "~s" es-script))
	       :wait wait?))

(provide "srpmix/emacs")