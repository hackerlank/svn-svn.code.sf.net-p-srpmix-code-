(define-module yogomacs.domain
  (export in-domain?
	  to-domain?)
  (use srfi-1)
  (use srfi-13)
  )

(select-module yogomacs.domain)

(define (in-domain? path config)
  (cond
   ((eq? (string-length path) 0) #f)
   ((not (eq? (string-ref path 0) #\/)) #f)
   (else
    (or 
     (string-prefix? (config 'real-sources-dir)
		     path)
     (any (cute string-prefix? <> path) (config 'domains))))))

(define (realpath path)
  #;(sys-realpath symlink)
  path)

(define (to-domain? symlink config)
  (in-domain? (realpath symlink)
	      config))

(provide "yogomacs/domain")