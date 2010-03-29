(define-module trapeagle.filter
  (export <filter>
	  read)
  (use trapeagle.pp-common))

(select-module trapeagle.filter)

(define (redirect symbol . proc)
  (if (null? proc)
      (lambda (o) (slot-ref o symbol))
      (if (procedure-arity-includes? (car proc) 2)
	  (lambda (o v) (slot-set! o symbol ((car proc) o v)))
	  (lambda (o v) (slot-set! o symbol ((car proc) v))))))


;; TODO (* read :xargs 1)
;; (type syscall kwd)
(define (compile-rules rules)
  (let1 type-table (make-hash-table 'eq?)
	(let loop ((rules rules))
	  (if (null? rules)
	      type-table
	      (let* ((rule (car rules))
		     (type (ref rule 0))
		     (syscall (ref rule 1))
		     (kwd   (ref rule 2)))
		(hash-table-update! type-table
				    type
				    (lambda (syscall-table)
				      (hash-table-update! syscall-table
							  syscall
							  (lambda (kwd-list)
							    kwd-list
							    (cons  kwd kwd-list)
							    )
							  (list))
				      syscall-table)
				    (make-hash-table 'eq?))
		(loop (cdr rules)))))))

(define (kdrop klist key)
  (reverse (let loop ((input klist)
		      (result (list)))
	     (cond
	      ((null? input) result)
	      ((eq? (car input) key)
	       (if (null? (cdr input))
		   ;; broken klist
		   result
		   (loop (cddr input) result)))
	      (else
	       (loop (cdr input) (cons (car input) result)))))))

(define (kreplace klist key value)
  (reverse (let loop ((input klist)
		      (result (list)))
	     (cond
	      ((null? input) result)
	      ((eq? (car input) key)
	       (loop (if (null? (cdr input))
			 (list)
			 (cddr input))
		     (cons value (cons key result)))
	       )
	      (else
	       (loop (cdr input) (cons (car input) result)))))))

(define (apply-rules rules strace)
  (let* ((type (ref strace 1))
	 (syscall (cadr (or (memq :call strace)
			    (list #f #f)
			    ))))
    (or (and-let* ((syscall-table (ref rules type #f))
		   (kwd-list      (ref syscall-table syscall #f)))
		  (let loop ((strace strace)
			     (kwd-list kwd-list))
		    (if (null? kwd-list)
			strace
			(loop (kreplace strace (car kwd-list) `filtered)
			      (cdr kwd-list)))))
	strace)))

(define-class <filter> ()
  ((input-port :init-keyword :input-port
	       :init-form (current-input-port))
   (rules     :init-keyword :rules
	       :allocation :virtual
	       :slot-set! (redirect 'rules0 compile-rules)
	       :slot-ref  (redirect 'rules0))
   (rules0)))

(define-method read ((filter <filter>))
  (let1 r (read (ref filter 'input-port))
	(if (eof-object? r)
	    r
	    (apply-rules (ref filter 'rules) r))))
(provide "trapeagle/filter")