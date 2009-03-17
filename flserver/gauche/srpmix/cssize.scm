(define-module srpmix.cssize

  (use file.util)
  (use gauche.process)

  (use srpmix.config)
  (use srpmix.emacs)
  (export cssize)
  )

(define (script-ccsize face path)
  (list 'flserver-cssize
	face
	path))

(define (path-for-face face)
  ;; TODO
  )

(define (cssize face err-return)
  (let1 path (path-for-face face)
    (if (file-is-readable? path)
	#t
	(let1 p (run-emacs socket-file
			   (script-ccsize face path)
			   #t)
	  (unless (eq? (process-exit-status p) 0)
	    (err-return "failed in cssize"))
	  (if (file-is-readable? path)
	      #t
	      #f)))))
