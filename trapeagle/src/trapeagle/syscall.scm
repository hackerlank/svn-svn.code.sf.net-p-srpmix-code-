(define-module trapeagle.syscall
  (export syscalls
	  syscall-arity-check
	  defsyscall
	  lambda*)
  (use trapeagle.type))

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

(provide "trapeagle/syscall")