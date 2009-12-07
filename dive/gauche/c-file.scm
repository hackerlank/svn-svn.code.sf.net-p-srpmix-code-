(define (make-in-session session id class . args)
  (let1 o (apply make class args)
    (set! (ref (ref session 'ids) id) o)
    o))

(define-class <session> ()
  (
   (debug-files :init-form (make-hash-table 'equal?))
   (ids         :init-form (make-hash-table 'eq?))
   ))

(define-class <debug-file> ()
  (
   (name :init-keyword :name)
   (current)
   (compile-units :init-form (make-hash-table 'equal?)) 
   ))

(define-class <compile-unit> ()
  (
   (name :init-keyword :name)
   (language :init-keyword :language)
   (debug-file :init-keyword :debug-file)
   ))
  

(define-method set-compile-unit ((debug-file <debug-file>)
				 (compile-unit <compile-unit>))
  (set! (ref (ref debug-file 'compile-units) 
	     (ref compile-unit 'name)) 
	compile-unit)
  (set! (ref debug-file 'current) compile-unit))


(define (load-compile-unit session u)
  (let ((name (cadr (memq :name u)))
	(filename (cadr (memq :filename u)))
	(language (cadr (memq :language u)))
	)
    (let1 d-o (or (ref (ref session 'debug-files) 'debug-file #f)
		(let1 d (make <debug-file> :name filename)
		  (set! (ref (ref session 'debug-files) 'debug-file)
			d)
		  d))
      (set-compile-unit d-o (make <compile-unit> 
			      :name name
			      :language language
			      :debug-file d-o)))))

(define (load-libdwarves session d)
  (case (car d)
    ('compile_unit
     (load-compile-unit session (cdr d))
     )
    
    ))


(define (main args)
  (let1 session (make <session>)
    (let loop ((r (read)))
      (unless (eof-object? r)
	(case (car r)
	  ('libdwarves
	   (load-libdwarves session (cdr r))
	   ))
	(loop (read))
	))
    (hash-table-for-each 
     (ref session 'debug-files)
     (lambda (k v)
       (format #t "~a:\n" (ref v 'name))
       (hash-table-for-each 
	(ref v 'compile-units)
	(lambda (k v)
	  (format #t "	~a:\n" (ref v 'name))))))))



			   
  