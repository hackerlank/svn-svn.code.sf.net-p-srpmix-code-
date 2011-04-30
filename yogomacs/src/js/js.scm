;;
;; JS <-> Scheme interface
;;
(define (export var val)
  (js-field-set! *js* var val))

(define (js-undefined? val)
  (eq? val (js-field *js* "abcdefghijklmnopqrstuvwxyz")))

(define (scm-name->js-name symbol)
  (list->string (map (lambda (c) (if (eq? c #\-)
				     #\_
				     c))
		     (string->list (symbol->string symbol)))))

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

(define (alist->object a)
  (let1 o (js-new Object)
    (for-each
     (lambda (elt)
       (js-field-set! o 
		      (let1 key (car elt)
			(if (string? key)
			    key
			    (symbol->string key)))
		      (cdr elt)))
     a)
    o))

(define (read-from-response response)
  (read-from-string response.responseText))

