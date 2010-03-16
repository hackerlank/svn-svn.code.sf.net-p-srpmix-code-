(define-class <fd> ()
  ((open-call :init-keyword :open-call)
   (open-args :init-keyword :open-args)
   (close-depth :init-value #f)
   (read-total :init-value 0)
   (write-total :init-value 0)
   (bind? :init-value #f)
   (connect? :init-value 0)
   (connect-args :init-value #f)
   ))

(define (hash-table-peek ht key)
  (let1 r (hash-table-get ht key #f)
	(if r (car r)
	    #f)))

(define (record-open ht fd call raw-data)
  (let1 record (make <fd> :open-call call :open-args raw-data)
	(hash-table-push! ht fd record)))

(define (record-close ht fd depth)
  (let1 record (hash-table-peek ht fd)
	(if record
	    (set! (ref record 'close-depth) depth)
	    #f
	    )))

(define (record-read ht fd size)
  (let1 record (hash-table-peek ht fd)
	(if record
	    (begin (set! (ref record 'read-total)
		  (+ (ref record 'read-total)
		     size)) #t)
	    #f
	    )))

(define (record-write ht fd size)
  (let1 record (hash-table-peek ht fd)
	(if record
	    (begin (set! (ref record 'write-total)
		  (+ (ref record 'write-total)
		     size)) #t)
	    #f
	    )))

(define (record-bind ht fd)
  (let1 record (hash-table-peek ht fd)
	(if record
	    (begin (set! (ref record 'bind?) #t) #t)
	    #f)))

(define (record-connect ht fd status args)
  (let1 record (hash-table-peek ht fd)
	(if record
	    (begin (set! (ref record 'connect?) status) 
		   (set! (ref record 'connect-args) args) 
		   #t)
	    #f)))

(define (accumulate r
		    fd-tables)
  (let ((call (cadr (memq :call r)))
	(rvalue (cadr (memq :rvalue r)))
	(args   (cadr (memq :args r)))
	(xargs   (cadr (memq :xargs r))))
    (cond
     ((memq call '(close))
      (when (>= rvalue 0)
	    (or (record-close fd-tables 
			  (string->number ((#/([0-9]+)/ args) 1))
			  2)
		(begin (write r (current-error-port)) (newline (current-error-port))))))
     ((memq call '(shutdown))
      (when (>= rvalue 0)
	    (or (record-close fd-tables 
			      (string->number ((#/([0-9]+),.*/ args) 1))
			      (string->number ((#/([0-9]+), *([0-9]).*/ args) 2)))
		(begin (write r (current-error-port)) (newline (current-error-port))))))

     ((memq call '(open socket accept))
      (when (>= rvalue 0)
	    (record-open fd-tables rvalue call 
			 r)))
     ((memq call '(dup2))
      (when (>= rvalue 0)
	    (let1 original (string->number ((#/([0-9]+),.*/ args) 1))
		  (record-open fd-tables rvalue call 
			       (reverse
				(cons (list :open-call (ref (hash-table-peek fd-tables original) 'open-call)
					    :open-args (ref (hash-table-peek fd-tables original) 'open-args))
				      (cons :orignal
					    (reverse r))))))))
     ((memq call '(pipe))
      (when (>= rvalue 0)
	    (record-open fd-tables (ref (car xargs) 1) call r)
	    (record-open fd-tables (ref (car xargs) 2) call r)
	    ))

     ((memq call '(read recv recvfrom recvmsg readv))
      (when (>= rvalue 0)
	    (or (record-read fd-tables 
			     (string->number ((#/([0-9]+),.*/ args) 1))
			     rvalue)
		(begin (write r (current-error-port)) (newline (current-error-port))))))
     ((memq call '(write send sendto sendmsg writev))
      (when (>= rvalue 0)
	    (or (record-write fd-tables 
			      (string->number ((#/([0-9]+),.*/ args) 1))
			      rvalue)
		(begin (write r (current-error-port)) (newline (current-error-port))))))
     ((memq call '(bind))
      (when (>= rvalue 0)
	    (or (record-bind fd-tables 
			     (string->number ((#/([0-9]+),.*/ args) 1)))
		(begin (write r (current-error-port)) (newline (current-error-port))))))
     ((memq call '(connect))
      (or (record-connect fd-tables 
			  (string->number ((#/([0-9]+),.*/ args) 1))
			  (if (eq? rvalue 0)
			      2
			      1)
			  args)
	  (begin (write r (current-error-port)) (newline (current-error-port))))))))

(define (main args)
  (define fd-tables (make-hash-table 'eq?))
  (define proc-tables (make-hash-table 'eq?))
  (let loop ((r (read)))
    (unless  (eof-object? r)
	     (when (eq? (car r) 'strace)
		   (cond
		    ((eq? (cadr r) 'trace)
		     (accumulate (list-tail r 4)
				 fd-tables))
		    ((eq? (cadr r) 'unfinished)
		     (hash-table-put! proc-tables
				      (cadr (memq :pid r))
				      (cadr (memq :call r))))
		    ((eq? (cadr r) 'resumed)
		     (let* ((pid (cadr (memq :pid r)))
			    (call (hash-table-get proc-tables pid)))
		       (accumulate (cons :call (cons call (list-tail r 6)))
				   fd-tables)))))
	     (loop (read))))
  (map
   (lambda (fd)
     (let1 records (hash-table-get fd-tables fd)
	   (print-record fd (car records))
	   ))
   (sort (hash-table-keys fd-tables) <)))

(define (print-record fd record)
  (unless (ref record 'close-depth)
	  (when (or (eq? (ref record 'open-call) 'socket)
		    (eq? (ref record 'open-call) 'dup2))
		(format #t "FD: ~d\n" fd)
		(format #t "open-call: ~d\n" (ref record 'open-call))
		(format #t "open-args: ~s\n" (ref record 'open-args))
		(format #t "close-depth: ~s\n" (ref record 'close-depth))
		(format #t "read-total: ~s\n" (ref record 'read-total))
		(format #t "write-total: ~s\n" (ref record 'write-total))
		(format #t "bind?: ~s\n" (ref record 'bind?))
		(format #t "connect?: ~s\n" (ref record 'connect?))
		(when (> (ref record 'connect?) 0)
		      (format #t "connect-args: ~s\n" (ref record 'connect-args)))
		(newline))))
		      