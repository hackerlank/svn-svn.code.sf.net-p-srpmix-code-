(define-module srpmix.emacs
  (use srfi-1)
  (use gauche.process)
    
  (export run-emacs
	  script-htmlize)
  )
(select-module srpmix.emacs)

(define emacsclient "/home/masatake/tools/bin/emacsclient")

(define (script-htmlize path output-file range)
  (list 'flserver-htmlize 
	path
	output-file
	(list 'quote (if range 
			 (list (car range)
			       (last range))
			 'nil))))

(define (run-emacs socket-path es-script wait?)
  (run-process (list emacsclient
		     (format "--socket-name=~a" socket-path)
		     "--eval" (format "~s" es-script))
	       :wait wait?))

(provide "srpmix/emacs")