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

