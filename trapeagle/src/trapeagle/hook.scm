(define-module trapeagle.hook
  (use gauche.hook)
  (export quit
	  quit-hook
	  input
	  input-hook))
(select-module trapeagle.hook)

(define quit-hook (make-hook 1))
(define (quit n)
  (quit-hook n)
  (exit n))
  
(define input-hook (make-hook 1))
(define (input i real-hanlder)
  (input-hook i)
  (real-hanlder i))

(provide "trapeagle/hook")
