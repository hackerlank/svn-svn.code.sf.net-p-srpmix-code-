(define-module trapeagle.pre.stripper
  (export <stripper>
	  read)
  (use trapeagle.pre-common))

(select-module trapeagle.pre.stripper)

(define (redirect symbol . proc)
  (if (null? proc)
      (lambda (o) (slot-ref o symbol))
      (if (procedure-arity-includes? (car proc) 2)
	  (lambda (o v) (slot-set! o symbol ((car proc) o v)))
	  (lambda (o v) (slot-set! o symbol ((car proc) v))))))


;; TODO (* read :xargs 1) 
;; (type syscall kwd N)
(define-method ref ((list <null>)
		    (index <integer>)
		    default)
  default)

(define-method ref ((list <pair>)
		    (index <integer>)
		    default)
  (if (< index (length list))
      (ref list index)
      default))

(define-method ref ((list <pair>)
		    (kwd  <keyword>))
  (kget kwd list))

(define-method ref ((list <pair>)
		    (kwd  <keyword>)
		    default)
  (kget kwd list default))
		    
(define (compile-rules rules)
  (let1 type-table (make-hash-table 'eq?)
    (let loop ((rules rules))
      (if (null? rules)
	  type-table
	  (let* ((rule (car rules))
		 (type (ref rule 0))
		 (syscall (ref rule 1))
		 (kwd   (ref rule 2))
		 (index (ref rule 3 #f)))
	    (if (eq? type '*)
		(loop (append 
		       (map
			(cute list <> syscall kwd index)
			'(trace signaled killed unfinished resumed))
		       (cdr rules)))
		(begin (hash-table-update! type-table
					   type
					   (lambda (syscall-table)
					     (hash-table-update! syscall-table
								 syscall
								 (lambda (kwd-list)
								   kwd-list
								   (cons  (list kwd index) kwd-list)
								   )
								 (list))
					     syscall-table)
					   (make-hash-table 'eq?))
		       (loop (cdr rules)))))))))

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

(define kget
  (case-lambda
   ((klist key default)
    (cond
     ((null? klist) default)
     ((eq? (car klist) key) (cadr klist))
     (else (kget (cdr klist) key default))))
   ((klist key)
    (kget klist key #f))))

(define (apply-rules rules strace)
  (let* ((type (ref strace 1))
	 (syscall (cadr (or (memq :call strace)
			    (list #f #f)
			    ))))
    (or (and-let* ((syscall-table (ref rules type #f))
		   (kwd-list      (or (ref syscall-table syscall #f)
				      (ref syscall-table '* #f)
				      )))
	  (let loop ((strace strace)
		     (kwd-list kwd-list))
	    (if (null? kwd-list)
		strace
		(let ((kwd (car (car kwd-list)))
		      (index (cadr (car kwd-list))))
		    (loop (replace! strace kwd index '|;|)
			  (cdr kwd-list))))))
	strace)))

(define (replace! strace kwd index value)
  (if index
      (let1 old (kget strace kwd)
	    (when old
		  (set-car! (list-tail old index) value))
	    strace)
      (kreplace strace kwd value)
      ))

(define-class <stripper> ()
  ((input-port :init-keyword :input-port
	       :init-form (current-input-port))
   (rules     :init-keyword :rules
	      :allocation :virtual
	      :slot-set! (redirect 'rules0 compile-rules)
	      :slot-ref  (redirect 'rules0))
   (rules0)))

(define-method read ((stripper <stripper>))
  (let1 r (read (ref stripper 'input-port))
    (if (eof-object? r)
	r
	(apply-rules (ref stripper 'rules) r))))
(provide "trapeagle/pre/stripper")