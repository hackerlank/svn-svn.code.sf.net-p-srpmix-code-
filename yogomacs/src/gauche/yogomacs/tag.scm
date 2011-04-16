(define-module yogomacs.tag
  (export has-tag?
	  define-tag-handler
	  tag-handlers
	  <tag-handler>)
  (use util.list)
  (use srfi-1)
  )

(select-module yogomacs.tag)

(define-class <tag-handler> ()
  ((has-tag? :init-keyword :has-tag? :init-value #f)))

(define tag-handlers (make-hash-table 'eq?))
(define-macro (define-tag-handler name . rest)
  `(hash-table-put! tag-handlers ',name
		    (make <tag-handler> ,@rest)))
	  
(define (has-tag? real-src-path config params)
  (hash-table-any 
   (lambda (name obj)
     (if-let1 proc (ref obj 'has-tag?)
	      (proc name real-src-path config params)
	      #f))
   tag-handlers))

(define (hash-table-any pred ht)
  (any
   (lambda (entry)
     (pred (car entry) (cdr entry)))
   (hash-table->alist ht)))

(provide "yogomacs/tag")