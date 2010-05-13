(define-module trapeagle.control
  (export
   controls
   defcontrol
   control
   all-controls
   document-for-control))
(select-module trapeagle.control)

(define controls (make-hash-table 'eq?))
(define-macro (defcontrol call args doc . body)
  `(set! (ref controls ',call) (vector (lambda ,args ,@body)
				 ,doc
				 )))
(define (control kernel c args)
  (apply (ref (ref controls c) 0) kernel args))

(define (all-controls)
  (hash-table-keys controls))

(define (document-for-control control)
  (let1 slot (ref controls control #f)
    (if slot
	(ref slot 1)
	slot)))

(provide "trapeagle/control")