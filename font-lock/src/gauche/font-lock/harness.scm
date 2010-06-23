(define-module font-lock.harness
  (export <harness>
	  name-of
	  launch
	  ;;
	  define-harness
	  all-harnesses
	  choose-harness
	  ;;
	  parameters-of
	  help-string-of
	  )
  )

(select-module font-lock.harness)

(define-class <harness> ()
  ((name :getter name-of)))

(define-method parameters-of ((harness <harness>)) (list))

(define-method launch ((harness <harness>)
		       cmdline
		       params
		       verbose))

(define-values 
  (define-harness all-harnesses choose-harness)
  (let ((harnesses (list)))
    (values
     (lambda (harness) (set! harnesses (cons harness harnesses)))
     (lambda () (sort harnesses (lambda (a b)
				  (string<? (name-of a) (name-of b)))))
     (lambda (name) (find (lambda (harness) (equal? (name-of harness) name)) harnesses)))))

(define-method help-string-of (parameter) 
  parameter)

(provide "font-lock/harness")