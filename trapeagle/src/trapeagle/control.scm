(define-module trapeagle.control
  (export
   controls
   defcontrol
   control))
(select-module trapeagle.control)

(define controls (make-hash-table 'eq?))
(define-macro (defcontrol call args . body)
  `(set! (ref controls ',call) (lambda ,args ,@body)))
(define (control kernel c args)
  (apply (ref controls c) kernel args))

;(defcontrol help ...

(provide "trapeagle/control")