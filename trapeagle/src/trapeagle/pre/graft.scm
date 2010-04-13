(define-module trapeagle.pre.graft
  (export <grafter> 
	  read)
  (use util.queue)
  (use trapeagle.pre-common)
  (use srfi-1)
  )
(select-module trapeagle.pre.graft)
(debug-print-width #f)

(define-class <grafter> ()
  ((input-port :init-keyword :input-port
	       :init-form (current-input-port))
   (proc-table :init-form (make-hash-table 'eq?))
   (solved :init-form (make-queue))
   (unsolved :init-form (make-queue))))

(define-method read ((grafter <grafter>))
  (let1 r (read (ref grafter 'solved))
    (if (eof-object? r)
	(let loop ((r (read (ref grafter 'input-port))))
	  (if (eof-object? r)
	      (read (ref grafter 'unsolved))
	      (if (strace? r)
		  (case (state-of r)
		    ('unfinished 
		     (let* ((pid (cadr (memq :pid r)))
			    (proc-table (ref grafter 'proc-table))
			    (old-unfinished (ref proc-table pid #f)))
		       (when old-unfinished
			 (format (current-error-port) ";; <error> double unfinished: ~s\n"
				 old-unfinished))
		       (let1 r (append! r (list :solved? #f))
			 (set! (ref proc-table pid) r)
			 (enqueue! (ref grafter 'unsolved) r)
			 (loop (read (ref grafter 'input-port))))))
		    ('resumed 
		     (let* ((pid (cadr (memq :pid r)))
			    (proc-table (ref grafter 'proc-table))
			    (unfinished (ref proc-table pid #f)))
		       (unless unless
			 (format (current-error-port) ";; <error> no unfinished: ~s\n" r))
		       (solved! unfinished r)
		       (hash-table-delete! proc-table pid)
		       (enqueue! grafter r)
		       (solved! grafter)
		       (read grafter)
		       ))
		    (else
		     (enqueue! grafter r)
		     (read grafter)))
		  (begin (enqueue! grafter r)
			 (read grafter))
		  )))
	r)))

(define-method enqueue! ((grafter <grafter>) 
			 r)
  (if (queue-empty? (ref grafter 'unsolved))
      (enqueue! (ref grafter 'solved) r)
      (enqueue! (ref grafter 'unsolved) r)))

(define (strace? call)
  (eq? (car call) 'strace))
(define (state-of call)
  (cadr call))
(define (solved? call)
  (cadr (memq :solved? call)))
(define-method solved! ((unfinished <list>)
			(resumed <list>))
  (set-car! (cdr (memq :solved? unfinished)) 
	    (cadr (memq :index resumed))))

(define-macro (define-safe-queue-op unsafe-op)
  (let1 unsafe-name (symbol->string unsafe-op)
     (let1 safe-op (string->symbol
		    (if (#/(.*)!$/  unsafe-name)
			(string-append
			 (substring unsafe-name
				    0 
				    (- (string-length unsafe-name) 1))
			 "-safe!")
			(string-append
			 unsafe-name
			 "-safe")))
       `(define (,safe-op queue . default)
	  (if (queue-empty? queue)
	      (if (null? default)
		  #f
		  (car default))
	      (,unsafe-op queue))))))
       
(define-safe-queue-op queue-front)
(define-safe-queue-op dequeue!)

(define-method solved! ((grafter <grafter>))
  (define (transfer unsolved solved)
    (enqueue! solved (dequeue! unsolved)))
  (let* ((unsolved (ref grafter 'unsolved))
	 (solved (ref grafter 'solved)))
    (let loop ((call (queue-front-safe unsolved)))
      (when call
	(if (strace? call)
	    (case (state-of call)
	      ('unfinished
	       (when (solved? call)
		 (transfer unsolved solved)
		 (loop (queue-front-safe unsolved))))
	      (else
	       (transfer unsolved solved)
	       (loop (queue-front-safe unsolved))))
	    (begin 
	      (transfer unsolved solved)
	      (loop (queue-front-safe unsolved))))))))


(define-method read  ((queue <pair>))
  (dequeue-safe! queue (eof-object)))

(provide "trapeagle/pre/graft")
