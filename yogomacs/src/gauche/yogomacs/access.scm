(define-module yogomacs.access
  (export readable?
	  directory?
	  )
  (use file.util)
  (use util.match)
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

(define readable?
   (match-lambda*
    ((dir ent)
     (file? dir ent file-is-readable?))
    ((file)
     (readable? (sys-dirname file) (sys-basename file)))))

(define (directory? dir ent)
  (file? dir ent file-is-directory?))

(provide "yogomacs/access")
