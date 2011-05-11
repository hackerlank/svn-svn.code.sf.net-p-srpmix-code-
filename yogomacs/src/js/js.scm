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

;; http://livepipe.net/extra/cookie
;; string key;
;; lisp_val val;
(define (cookie-set! key val)
  (Cookie.set key
	      (write-to-string val)))

(define (js-escape-string str)
  ;; TODO
  str)