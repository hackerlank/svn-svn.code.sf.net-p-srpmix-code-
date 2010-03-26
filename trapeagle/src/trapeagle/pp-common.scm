(define-module trapeagle.pp-common
  (export read))
(select-module trapeagle.pp-common)

(define read-from-iport read)
(define-generic read)

(define-method read ((iport <port>))
  (read-from-iport iport))

(provide "trapeagle/pp-common")
  