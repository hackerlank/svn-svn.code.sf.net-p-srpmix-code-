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

(define (run-hook hook . args)
  (let ((hook-name (vector-ref hook 0))
	(params (vector-ref hook 1))
	(procs (vector-ref hook 2)))
    (if (eq? (length params) (length args))
	(for-each (lambda (proc) (apply proc args)) (reverse procs))
	(alert (string-append "Given args doesn't match parameters: " 
			      hook-name
			      ", given: " (number->string (length args))
			      ", expected: " (number->string (length params))
			      ))
	)))
