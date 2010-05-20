(define-module yogomacs.cssize

  (use file.util)
  (use gauche.process)

  (use yogomacs.config)
  (use yogomacs.emacsclient)
  (export cssize
	  file-for-face)
  )

(select-module yogomacs.cssize)

(define (script-cssize face path)
  `(flserver-cssize
    ',face
    ,path))

(define (path-for-face face)
  (build-path css-dir (file-for-face face))
  )

(define (file-for-face face)
  (format "~a.css" (x->string face)))

(define (cssize face err-return)
  (let1 path (path-for-face face)
    (if (file-is-readable? path)
	#t
	(let1 p (run-emacsclient socket-file
				 (script-cssize face path)
				 #t)
	  (unless (eq? (process-exit-status p) 0)
	    (err-return "failed in cssize"))
	  (if (file-is-readable? path)
	      #t
	      #f)))))

(provide "yogomacs/cssize")
