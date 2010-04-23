(define-module trapeagle.controls.repl
  (use trapeagle.control))

(define (prompt)
    (display ";trapeagle> " (current-error-port)))
(define (repl kernel)
  (prompt)
  (let1 r0 (read)
    (if (eof-object? r0)
	(with-input-from-file "/dev/tty"
	  (lambda () (repl0 kernel #f)))
	(begin 
	  (control kernel (car r0) (cdr r0))
	  (repl0 kernel #t)))))

(define (repl0 kernel print-prompt?)
  (let loop ((print-prompt? print-prompt?))
    (when print-prompt?
      (prompt))
    (let1 r (read)
      (if (eof-object? r)
	  (exit 0)
	  (begin (control kernel (car r) (cdr r))
		 (loop #t))))))

(defcontrol repl (kernel . args)
  (repl kernel))

(defcontrol quit (kernel . args)
  (exit 0))

(provide "trapeagle/controls/repl")
