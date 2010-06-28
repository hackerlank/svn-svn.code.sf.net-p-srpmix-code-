(define-module yogomacs.access
  (export readable?
	  directory?
	  )
  (use file.util)
  )
(select-module yogomacs.access)

(define (file? dir ent condition)
  (let1 real (directory-list dir
			     :add-path? #t
			     :children? #f
			     :filter (cute equal? ent <>))
    (if (null? real)
	#f
	(if (condition (car real))
	    (car real)
	    #f))))

(define (readable? dir ent)
  (file? dir ent file-is-readable?))

(define (directory? dir ent)
  (file? dir ent file-is-directory?))

(provide "yogomacs/access")
