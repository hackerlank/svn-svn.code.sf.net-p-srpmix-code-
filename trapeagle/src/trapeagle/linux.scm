(define-module trapeagle.linux
  (export <linux>
	  syscall)
  (use trapeagle.resource))

(select-module trapeagle.linux)


(define-class <linux> ()
  ((task-table :init-value (make-hash-table 'eq?))
   ))

(define syscalls (make-hash-table 'eq?))
(define-macro (defsyscall call . rest)
  `(let-keywords ,(cons 'list rest) ((trace-fn :trace (lambda args #f))
				     (unfinished-fn :unfinished (lambda args #f))
				     (resumed-fn :resumed (lambda args #f))
				     (unfinished-exit-fn :unfinished-exit (lambda args #f)))
     (unless (procedure-arity-includes? trace-fn 6)
       (errorf "handler for `~s' take too few arguments" :trace))
     (set! (ref ,syscalls ',call)
	   (vector trace-fn unfinished-fn resumed-fn unfinished-fn))))

(defsyscall open
  :trace 
  (lambda (kernel pid xargs xrvalue xerrno index)
    #f)
  )

(define-method syscall ((kernel <linux>)
			strace)
  (let1 type (car strace)
    (car type
	 ('trace
	  )
	 ('unfinished
	  )
	 ('resumed
	  )
	 ('signaled
	  )
	 ('killed
	  )
	 ('unfinished-killed
	  )
	 (else
	  ))))

(define-method dump ((kernel <linux>))
  )


(provide "trapeagle/linux")