(use gauche.parseopt)
(use srfi-13)
(use srfi-1)

(debug-print-width #f)
(define (split-name name)
  (let loop ((name name)
	     (result (list)))
    (if (equal? "" name)
	(map string-downcase (reverse result))
	(rxmatch-cond
	  ((#/^([A-Z]+)([A-Z][a-z0-9]+)(.*)$/ name)
	   (#f w0 w1 rest)
	   (loop rest (cons w1 (cons w0 result)) ))
	  ((#/^([A-Za-z0-9]+)[_-](.*)$/ name)
	   (#f w rest)
	   (loop rest (cons w result)))
	  ((#/^[_-]([A-Za-z0-9]+)(.*)$/ name)
	   (#f w rest)
	   (loop rest (cons w result)))
	  (else
	   (loop "" (cons name result))
	  )))))

(define (make-in-session session id class . args)
  (let1 o (apply make class args)
    (set! (ref (ref session 'ids) id) o)
    o))

(define-class <context> ()
  (
   (current)
   ))
(define-class <session> (<context>)
  (
   (debug-files :init-form (make-hash-table 'equal?))
   (raw-names  :init-form (list))
   (names :init-form (list))
   (subwords :init-form (list))
   ))

(define-class <debug-file> (<context>)
  (
   (name :init-keyword :name)
   (ids         :init-form (make-hash-table 'eq?))
   (compile-units :init-form (make-hash-table 'equal?)) 
   ))

(define-class <compile-unit> ()
  (
   (name :init-keyword :name)
   (language :init-keyword :language)
   (debug-file :init-keyword :debug-file)
   (subprograms :init-form (make-hash-table 'equal?))
   (variables   :init-form (make-hash-table 'equal?))
   )
  )

(define-class <subprogram> ()
  (
   (name :init-keyword :name)
   (return :init-keyword :return)
   (parameters :init-keyword :parameters)
   (lexblock :init-keyword :lexblock)
   (external :init-keyword :external)
   (id :init-keyword :id)
   (file :init-keyword :file)
   (line :init-keyword :line)
   ))

(define-class <variable> ()
  (
   (name :init-keyword :name)
   (type :init-keyword :type)
   (external :init-keyword :external)
   (declaration :init-keyword :declaration)
   (id :init-keyword :id)
   (file :init-keyword :file)
   (line :init-keyword :line)
   ))

(define-method set-compile-unit! ((debug-file <debug-file>)
				  (compile-unit <compile-unit>))
  (set! (ref (ref debug-file 'compile-units) 
	     (ref compile-unit 'name)) 
	compile-unit)
  (set! (ref debug-file 'current) compile-unit))
(define-method set-debug-file! ((session <session>)
				(debug-file <debug-file>))
  (set! (ref (ref session 'debug-files)
	     (ref debug-file 'name))
	debug-file)
  (set! (ref session 'current) debug-file))

(define (compile-unit session u)
  (let ((name (cadr (memq :name u)))
	(filename (cadr (memq :filename u)))
	(language (cadr (memq :language u)))
	)
    (let1 d-o (or (ref (ref session 'debug-files) filename #f)
		(let1 d (make <debug-file> :name filename)
		  (set-debug-file! session d)
		  d))
      (set-compile-unit! d-o (make <compile-unit> 
			      :name name
			      :language language
			      :debug-file d-o)))))

(define (record-subwords session name)
  (unless (member name (ref session 'raw-names))
    (slot-push! session 'raw-names name))
  (let1 subwords (split-name name)
    (unless (member subwords (ref session 'names))
      (slot-push! session 'names subwords)
      )
    (for-each
     (lambda (subword)
       (unless (member subword (ref session 'subwords))
	 (slot-push! session 'subwords subword )))
     subwords)))

(define (subprogram session debug-file compile-unit args)
  (let ((name (cadr (memq :name args)))
	(return (let1 r (cadr (memq :return args)) 
		  (if (eq? r 'VOID)
		      'VOID
		      (ref r 3))))
	(parameters (map (cute ref <> 3) (cadr (memq :parameters args))))
	(lexblock (ref (cadr (memq :lexblock args)) 3))
	(external (cadr (memq :external args)))
	(id (cadr (memq :id args)))
	(file (cadr (memq :file args)))
	(line (cadr (memq :line args))))
    (record-subwords session name)
    (let1 s (make <subprogram>
	      :name name
	      :return return
	      :parameters parameters
	      :external external
	      :lexblock lexblock
	      :id id
	      :file file
	      :line line)
      (set! (ref (ref debug-file 'ids) id) s)
      (set! (ref (ref compile-unit 'subprograms) name) s))))

(define (variable session debug-file compile-unit args)
  (let ((name (cadr (memq :name args)))
	(type (ref (cadr (memq :type args)) 3))
	(external (cadr (memq :external args)))
	(declaration (cadr (memq :declaration args)))
	(id (cadr (memq :id args)))
	(file (cadr (memq :file args)))
	(line (cadr (memq :line args))))
    (record-subwords session name)
    (let1 v (make <variable>
	      :name name
	      :type type
	      :external external
	      :declaration declaration
	      :id id
	      :file file
	      :line line)
      (set! (ref (ref debug-file 'ids) id) v)
      (set! (ref (ref compile-unit 'variables) name) v))))

(define (dump-subprograms compile-unit)
  (let1 subprograms (ref compile-unit 'subprograms)
    (for-each
     (lambda (s)
       (let1 extern? (ref (ref subprograms s) 'external)
	 (when extern?
	   (format #t "<subprogram>~s:~d~a\n" 
		   (split-name s)
		   (ref (ref subprograms s) 'line)
		   (if extern? "*" "")
		   ))))
     (sort (hash-table-keys subprograms)
	   (lambda (a b)
	     (let ((ra (ref subprograms a))
		   (rb (ref subprograms b)))
	       (if (and (ref ra 'external)
			(ref rb 'external))
		   (< (ref ra 'line)
		      (ref rb 'line))
		   (if (ref ra 'external)
		       #t
		       (if (ref rb 'external)
			   #f
			   (< (ref ra 'line)
			      (ref rb 'line)))))))))))

(define (dump-variables compile-unit)
  (let1 variables (ref compile-unit 'variables)
    (for-each
     (lambda (s)
       (let ((extern? (ref (ref variables s) 'external))
	     (declaration? (ref (ref variables s) 'declaration)))
	 (when (and (not declaration?) extern?)
	   (format #t "<variable>~s:~d~a\n" 
		   (split-name s)
		   (ref (ref variables s) 'line)
		   (if extern? "*" "")
		   ))))
     (sort (hash-table-keys variables)
	   (lambda (a b)
	     (let ((ra (ref variables a))
		   (rb (ref variables b)))
	       (if (and (ref ra 'external)
			(ref rb 'external))
		   (< (ref ra 'line)
		      (ref rb 'line))
		   (if (ref ra 'external)
		       #t
		       (if (ref rb 'external)
			   #f
			   (< (ref ra 'line)
			      (ref rb 'line)))))))))))

(define (included? short long)
    (let loop ((short short)
	       (long long))
      (list short long)
      (cond
       ((null? short)
	#t)
       ((null? long)
	#f)
       ((equal? (car short) (car long))
	(loop (cdr short) (cdr long)))
       (else
	#f))))
(define (find-longest-prefix name names)
  (let loop ((name name))
    (if (null? name)
	#f
	(if (any (lambda (x)
		   (included? name x))
		 names)
	    name
	    (loop (reverse (cdr (reverse name))))))))
		      
(define (dump-prefix session names)
  (print "preifx: ")
  (for-each
   (lambda (x)
     (write x)
     (newline)
     (for-each
      print
      (sort (fold
	     (lambda (kar kdr)
	       (if (included? x (split-name kar))
		   (cons kar kdr)
		   kdr))
	     (list)
	     (slot-ref session 'raw-names))
	   string<)))
   (sort (let loop ((prefixes (list))
		    (current-names names))
	   (if (null? current-names)
	       prefixes
	       (let1 prefix (find-longest-prefix (car current-names)
						 (delete (car current-names) names equal?))
		 (if (and prefix (not (member prefix prefixes)))
		     (loop (cons prefix prefixes) (cdr current-names))
		     (loop prefixes (cdr current-names))))))
	 (lambda (a b)
	   (string< (apply string-append a) (apply string-append b)))
	 )))

(define (dump-suffix names)
  )
(define (dump-debug-files session d)
  (write (cons 'debug-files
	       (hash-table-keys (ref session 'debug-files))))
  (newline)
  (dump-prefix session (ref session 'names))
  (dump-suffix (ref session 'names))
  (write (cons 'subwords (sort (ref session 'subwords)
			       string<)))
  (newline)
  (for-each
   (lambda (k)
     (for-each
      (lambda (u)
	(print (ref u 'name))
	(dump-subprograms u)
	(dump-variables u)
	)
      (hash-table-values (ref (ref (ref session 'debug-files) k) 'compile-units)))
     )
   (hash-table-keys (ref session 'debug-files))
  ))

(define (libdwarves session args)
  (case (car args)
    ('compile_unit
     (compile-unit session (cdr args))
     )
    (else
     (let* ((a (car args))
	    (d (ref session 'current))
	    (u (ref d 'current))
	    (args (cdr args)))
       (case a
	 ('subprogram
	  (subprogram session d u args))
	 ('variable
	  (variable session d u args))
	 )
       ))))

(define (control session action args)
  (when (eq? action 'dump)
    (case (car args)
      ('debug-files
       (dump-debug-files session (cdr args))))))


(define (show-help prog n)
  (format #t "~a --help\n" prog)
  (format #t "~a [--debug]\n" prog)
  (exit n))
(define (split-by pred lst)
  (let loop ((input   lst)
	     (pre (list))
	     (post  (list))
	     (found? #f))
    (if (null? input)
	(values (reverse pre) (reverse post))
	(if (pred (car input))
	    (loop (cdr input) pre post #t)
	    (if found?
		(loop (cdr input) pre (cons (car input) post) found?) 
		(loop (cdr input) (cons (car input) pre) post found?))))))
(define (read-list lst)
  (map read (map open-input-string lst)))

(define (main args)
  (define (consume-one s r)
    (cond 
     ((eq? (car r) 'libdwarves)
      (libdwarves s (cdr r)))
     ((eq? (car r)  'dive)
      (control s (cadr r) (cddr r)))))
  (let-args (cdr args)
      ((help "h|help" => (cute show-help (car args) 0))
       (debug "debug" #t)
       . rest)
    (receive (pre post) (split-by (pa$ equal? "-") rest)
      (let ((session (make <session>))
	    (pre-list (map (pa$ cons 'dive) (read-list pre)))
	    (post-list (map (pa$ cons 'dive) (read-list post))))
	(for-each (pa$ consume-one session) pre-list)
	(let loop ((r (read)))
	  (unless (eof-object? r)
	    (consume-one session r)
	    (loop (read))))
	(for-each (pa$ consume-one session) post-list)
	))))
  