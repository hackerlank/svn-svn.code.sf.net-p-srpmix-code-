(define-module trapeagle.hook
  (use gauche.hook)
  (export quit
	  quit-hook))
(select-module trapeagle.hook)

(define quit-hook (make-hook 1))
(define (quit n)
  (quit-hook n)
  (exit n))
  
(provide "trapeagle/hook")
