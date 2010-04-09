(define-module trapeagle.linux
  (export <linux>
	  syscall
	  dump
	  get-task)
  (use trapeagle.type)
  (use trapeagle.syscall)
  (use trapeagle.resource)
  )

(select-module trapeagle.linux)

(define-class <linux> ()
  ((init-task)
   (task-table :init-value (make-hash-table 'eq?))
   ))

(define-method init-task ((kernel <linux>) pid)
  (set! (ref kernel 'init-task)
	(make <process> 
	  :parent-tid #f
	  :tid pid))
  (set! (ref (ref kernel 'task-table) pid) (ref kernel 'init-task))
  (ref kernel 'init-task))

(define-method get-task ((kernel <linux>) pid)
  (let1 task (ref (ref kernel 'task-table) pid #f)
    (if task
	task
	(init-task kernel pid))))


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
  (let1 table (ref kernel 'task-table)
    (for-each
     (lambda (tid)  (dump (ref table tid)))
     (sort (hash-table-keys table) <))))

(provide "trapeagle/linux")