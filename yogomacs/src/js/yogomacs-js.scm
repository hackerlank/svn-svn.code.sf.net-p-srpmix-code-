;;
;; JS <-> Scheme interface
;;
(define (export var val)
  (js-field-set! *js* var val))

(define (run-hook hook . args)
  (for-each (lambda (proc) (apply proc args)) hook))

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

