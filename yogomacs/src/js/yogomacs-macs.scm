;;
;; Common scheme macros, no prefix. 
;;
(define-macro (let1 name val . body)
  `(let ((,name ,val))
     ,@body))
(define-macro (if-let1 name condition t f)
  `(let1 ,name ,condition
     (if ,name
	 ,t
	 ,f)))
(define-macro (when-let1 name condition . t)
  `(let1 ,name ,condition
     (when ,name
       ,@t)))

(define-macro (add-hook! hook proc)
  `(vector-set! ,hook 2 (cons ,proc (vector-ref ,hook 2))))

(define-macro (define-hook name params)
  (let ((scm-name (string->symbol (string-append (symbol->string name))))
	(js-name (gensym))
	(args (gensym)))
    `(begin
       (define ,scm-name '#(,scm-name ,params ,(list)))
       (export (string-append "run_" 
			      (scm-name->js-name ',scm-name)
			      ) (lambda ,args (apply run-hook ,scm-name ,args))))))


;; TAKEN FROM /srv/sources/sources/s/scheme2js/20090717-1.fc14/pre-build/scheme2js-20090717/tests/error.scm
(define-macro (with-error-handler handler f)
   `(with-handler ,handler
		  (,f)))


(define-macro (define-values symbols . body)
  (let ((parameters (map (lambda (sym) (gensym)) symbols)))
    `(begin
       ,@(map (lambda (sym)
		`(define ,sym #f))
	      symbols)
       (call-with-values (lambda () 
			   ,@body)
	 (lambda ,parameters
	   ,@(map (lambda (sym param)
		    `(set! ,sym ,param)
		    )
		  symbols
		  parameters))))))

(define-macro (debug exp)
  (let ((v (gensym)))
    `(let1 ,v ,exp
       (alert (list ',exp '=> ,v))
       ,v)))