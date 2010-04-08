(define-module trapeagle.linux
  (export <linux>
	  syscall
	  dump)
  (use trapeagle.type)
  (use trapeagle.syscall)
  (use trapeagle.resource)
  )

(select-module trapeagle.linux)

(define-class <linux> ()
  ((task-table :init-value (make-hash-table 'eq?))
   ))

(let ((nop-vector (make-vector (type-count) (lambda args #f))))
  (define-method syscall ((kernel <linux>)
			  strace)
    (let1 type (car strace)
      (case type
	((trace unfinished resumed unfinished-exit)
	 (let-keywords (cdr strace) ((call #f) . rest)
	   (apply 
	    (vector-ref (hash-table-get syscalls call nop-vector)
			(type-pos-of type))
	    kernel
	    (type-actual-params-for type (cdr strace)))
	   ))
	('signaled
	 )
	('killed
	 )
	(else
	 #f)))))

(define-method dump ((kernel <linux>))
  )

(provide "trapeagle/linux")