(define-module trapeagle.linux
  (export <linux>
	  syscall
	  dump)
  (use trapeagle.resource)
  )
(select-module trapeagle.linux)


(define-class <linux> ()
  ((task-table :init-value (make-hash-table 'eq?))
   ))

(define type-counter (let1 i 0 (lambda (inc?) (let1 r i (when inc? (inc! i)) r))))
(define type-infos (make-hash-table 'eq?)) ; [pos formal-params]
(define-macro (deftype type formal-params)
  (let1 v (ref type-infos type (make-vector 4 #f))
    (vector-set! v 0 type)
    (unless (ref v 1)
      (vector-set! v 1 (type-counter #t)))
    (vector-set! v 2 formal-params)
    (set! (ref type-infos type) v)
    (let1 pickers (map (lambda (param)
			 (lambda (strace)
			   strace
			   (get-keyword (make-keyword (symbol->string param)) strace)))
		       formal-params)
    `(vector-set! ,v 3 (lambda (strace)
			 (list ,@(map (lambda (p) `(,p strace)) pickers)))))))

(deftype trace (pid xargs xrvalue xerrno time index))
(deftype unfinished (pid resumed? time index))
(deftype resumed (pid xargs xrvalue xerrno unfinished? time index))
(deftype unfinished-exit-pos (pid))	; TODO

(define (type-format-params-of type)
  (vector-ref (hash-table-get type-infos type) 2))
(define (type-pos-of type)
  (vector-ref (hash-table-get type-infos type) 1))
(define (type-actual-params-for type strace)
  ((vector-ref (hash-table-get type-infos type) 3) strace))

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
    (let1 v (make-vector (type-counter #f))
      `(begin
	 ;; TODO
	 (syscall-arity-check ,trace trace ,call)
	 (syscall-arity-check ,unfinished unfinished ,call)
	 (vector-set! ,v (type-pos-of 'trace) ,trace)
	 (vector-set! ,v (type-pos-of 'unfinished) ,unfinished)
	 (vector-set! ,v (type-pos-of 'resumed) ,resumed)
	 (vector-set! ,v (type-pos-of 'unfinished) ,unfinished-exit)
	 (set! (ref ,syscalls ',call) ,v)))))

(defsyscall open
  :trace 
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (write xargs)
    (newline)
    #f)
  :unfinished
  (lambda (kernel pid resumed? time index)
    #f)
  )

(defsyscall socket
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (write xargs)
    (newline)
    #f)
  )
  

(let ((nop-vector (make-vector (type-counter #f) (lambda args #f))))
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