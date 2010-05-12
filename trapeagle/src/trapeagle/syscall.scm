(define-module trapeagle.syscall
  (export syscalls
	  syscall-arity-check
	  defsyscall
	  lambda*
	  syscall)
  (use trapeagle.type)
  (use trapeagle.linux))

(select-module trapeagle.syscall)

(define syscalls (make-hash-table 'eq?))

(define-macro (syscall-arity-check fn type call)
  `(unless (procedure-arity-includes? ,fn (+ (length (type-format-params-of ',type)) 1))
     (errorf "To few formal parameter: `~s' handler for `~s'" 
	     ',call
	     ',type)))

(define-macro (defsyscall call . rest)
  (let-keywords rest ((trace :trace (lambda args #f))
		      (unfinished :unfinished (lambda args #f))
		      (resumed :resumed (lambda args #f))
		      (unfinished-exit :unfinished-exit (lambda args #f)))
    (let1 v (make-vector (type-count))
      `(begin
	 ;; TODO
	 (syscall-arity-check ,trace trace ,call)
	 (syscall-arity-check ,unfinished unfinished ,call)
	 (syscall-arity-check ,resumed resumed ,call)
	 (vector-set! ,v (type-pos-of 'trace) ,trace)
	 (vector-set! ,v (type-pos-of 'unfinished) ,unfinished)
	 (vector-set! ,v (type-pos-of 'resumed) ,resumed)
	 (vector-set! ,v (type-pos-of 'unfinished) ,unfinished-exit)
	 (hash-table-push! ,syscalls ',call ,v)
	 ))))

(define-macro (lambda* args . body)
  `(lambda ,args
     (let1 $ ,(cons 'list args)
       ,@body)))

(let ((nop-vector (make-vector (type-count) (lambda args #f))))
  (define-method syscall ((kernel <linux>)
			  strace)
    (let1 type (car strace)
      (case type
	((trace unfinished resumed unfinished-exit)
	 (let-keywords (cdr strace) ((call #f) . rest)
	   (for-each (cute 
			apply 
			<>
			kernel
			(type-actual-params-for type (cdr strace)))
		     (map (cute vector-ref <> (type-pos-of type))
			  (append 
			   (hash-table-get syscalls #t (list nop-vector))
			   (hash-table-get syscalls call (list nop-vector))))
	   )))
	('signaled
	 )
	('killed
	 )
	(else
	 #f)))))

(provide "trapeagle/syscall")