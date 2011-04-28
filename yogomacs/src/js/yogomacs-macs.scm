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

(define-macro (add-hook hook proc)
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
