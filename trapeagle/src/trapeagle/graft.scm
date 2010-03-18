(define-module trapeagle.graft
  (export <grafter>)
  (use util.queue)
  )
(select-module trapeagle.graft)

(define-class <grafter> ()
  ((input-port :init-keyword :input-port
	       :init-form (current-input-port))
   (proc-tables :init-form (make-hash-table 'eq?))
   (backlog :init-form (make-queue))
   ))


(define-method read ((grafter <grafter>))
  (let loop ((r (read (ref grafter 'input-port))))
    (if (eof-object? r)
	;; FIXME return backlog
	r
	(if (eq? (car r) 'strace)
	    (case (cadr r)
	      ('trace r)
	      ('unfinished
	       ;; FIXME CHECK OVER WRITING
	       (set! (ref (ref grafter 'proc-tables) (cadr (memq :pid r))) r)
	       (queue! (ref grafter 'backlog) r)
	       (loop (read (ref grafter 'input-port)))
	       )
	      ('resumed
	       (let* ((pid (cadr (memq :pid r)))
		      (unfinished (ref (ref grafter 'proc-tables) pid)))
		 ;; ...
		 ;; ...
		 
	       )
	      )
	    r))))

(provide "trapeagle/graft")
