(define-module trapeagle.linux
  (export <linux>
	  syscall
	  report
	  task-for
	  fd-for)
  (use trapeagle.type)
  (use trapeagle.syscall)
  (use trapeagle.resource)
  (use trapeagle.report)
  )

(select-module trapeagle.linux)

(define-class <linux> ()
  ((init-task)
   (task-table :init-value (make-hash-table 'eq?))
   (syscalls   :init-form  (make-tree-map 
			    eq?
			    (lambda (a b) (string<? (symbol->string a) (symbol->string b)))))
   ))

(define-method init-task ((kernel <linux>) pid)
  (set! (ref kernel 'init-task)
	(make <process> 
	  :parent-tid #f
	  :tid pid))
  (set! (ref (ref kernel 'task-table) pid) (ref kernel 'init-task))
  (ref kernel 'init-task))

(define-method task-for ((kernel <linux>) tid)
  (let1 task (ref (ref kernel 'task-table) tid #f)
    (if task
	task
	(init-task kernel tid))))

(define-method fd-for ((kernel <linux>) tid fd)
  (and-let* ((task (task-for kernel tid))
	     (fd-table (ref task 'fd-table))
	     (fd (ref fd-table fd #f)))
    fd))

(define-method fd-for ((kernel <linux>) tid fd (fd-obj <fd>))
  (let* ((task (task-for kernel tid))
	 (fd-table (ref task 'fd-table)))
    (hash-table-put! fd-table fd fd-obj)))

(let ((nop-vector (make-vector (type-count) (lambda args #f))))
  (define-method syscall ((kernel <linux>)
			  strace)
    (let1 type (car strace)
      (case type
	((trace unfinished resumed unfinished-exit)
	 (tree-map-update!
	  (ref kernel 'syscalls) 
	  (cadr (memq :call strace))
	  (lambda (i) (+ i 1))
	  0)
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

(define-method report ((kernel <linux>) filter)
  (format #t "syscalls: ~s\n" (tree-map->alist (ref kernel 'syscalls)))
  (let ((table (ref kernel 'task-table))
	(condition (if (memq 'alive-only filter)
		       (complement dead?)
		       boolean)))
    (for-each
     (lambda (tid)  (let1 task (ref table tid)
		      (when (condition task)
			(report task filter))))
     (sort (hash-table-keys table) <))))

(provide "trapeagle/linux")