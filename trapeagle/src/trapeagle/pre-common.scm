(define-module trapeagle.pre-common
  (export read))
(select-module trapeagle.pre-common)

(define read-from-iport read)
(define-generic read)

(define-method read ((iport <port>))
  (read-from-iport iport))

(provide "trapeagle/pre-common")
  