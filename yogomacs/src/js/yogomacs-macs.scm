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
    `(begin
       (alert (list "debug: " ',exp))
       (let1 ,v ,exp
	 (alert (list ',exp '=> (with-output-to-string (lambda () (write ,v)))))
	 ,v))))

(define-macro (receive formals expression . body)
  `(call-with-values (lambda () ,expression)
     (lambda ,formals ,@body)))