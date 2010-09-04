(define-macro (let1 name val . body)
  `(let ((,name ,val))
     ,@body))				;???

(define-macro (add-hook hook proc)
  `(set! ,hook (cons ,proc ,hook)))

(define-macro (define-hook name)
  (let ((jname (string-append "run_" (list->string (map (lambda (c) (if (eq? c #\-)
									#\_
									c))
							(string->list (symbol->string name)))))))
    `(begin
       (define ,name (list))
       (export ,jname (lambda () (run-hook ,name))))))


;; TAKEN FROM /srv/sources/sources/s/scheme2js/20090717-1.fc14/pre-build/scheme2js-20090717/tests/error.scm
(define-macro (with-error-handler handler f)
   `(with-handler ,handler
		  (,f)))
