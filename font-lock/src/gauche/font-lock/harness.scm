(define-module font-lock.harness
  (export <harness>
	  name-of
	  launch
	  ;;
	  define-harness
	  all-harnesses
	  choose-harness
	  )
  )

(select-module font-lock.harness)

(define-class <harness> ()
  ((name :getter name-of)))

(define-method launch ((harness <harness>)
		       cmdline
		       params
		       verbose))

(define-values 
  (define-harness all-harnesses choose-harness)
  (let ((harnesses (list)))
    (values
     (lambda (harness) (set! harnesses (cons harness harnesses)))
     (lambda () harnesses)
     (lambda (name) (find (lambda (harness) (equal? (name-of harness) name)) harnesses)))))
  
(provide "font-lock/harness")