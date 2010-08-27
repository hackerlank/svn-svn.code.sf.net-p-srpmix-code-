(define-module yogomacs.access
  (export readable?
	  directory?
	  pickable?
	  archivable?
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

(define (pickable? path config)
  (any 
   (lambda (r) (r path))
   (map
    (lambda (r)
      (string->regexp
       (string-append (config 'real-sources-dir) 
		      (if (string? r)
			  r
			  (regexp->string r)))))
    (config 'pickable-regexps)
    )))

(define (archivable? path config)
  (and (pickable? path config)
       ;; ???
       (directory? (sys-dirname path)
		   (sys-basename path))))


(provide "yogomacs/access")
