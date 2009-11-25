#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(use util.list)

(define-class <process> ()
  ((pid   :init-keyword :pid)
   (ppid :init-keyword :ppid :init-value #f)
   (children :init-form (list))
   (cmdline :init-value #f :init-keyword :cmdline)
   (signaled :init-value #f)
   (signal-order :init-value #f)
   (status   :init-value #f)
   (unfinished :init-form (list))
   ))

(define (slot-pop! obj slot)
  (let1 value (slot-ref obj slot)
    (let1 r (car value)
      (slot-set! obj slot (cdr value))
      r)))

(define (main args)
  (let1 proc-table
      (let loop ((r (read))
		 (proc-table (make-hash-table 'eq?))
		 (signal-count 0))
	(if (eof-object? r)
	    proc-table
	    (if (eq? (car r) 'strace)
		(let1 type (cadr r)
		    (case type
		      ((trace unfinished resumed)
		       (let ((pid (cadr (memq :pid r)))
			     (call (cadr (memq :call r))))
			 (case call
			   ('execve
			    (when (eq? type 'trace)
			      (let ((proc (hash-table-get proc-table pid #f))
				    (cmdline 
				     (regexp-replace-all #/"/ ;"
						     (car (string-split (cadr (memq :args r)) #\,))
						     "")
					     ))
				(if proc
				    (set! (ref proc 'cmdline) cmdline)
				    (let1 proc (make <process> 
						 :pid pid
						 :cmdline cmdline)
				      (hash-table-put! proc-table
						       pid
						       proc))))))
			   ('_exit
			    (when (eq? type 'trace)
			      (let ((proc (hash-table-get proc-table pid #f))
				    (status  (cadr (memq :xargs r))))
				(set! (ref proc 'status) status))))
			   ((clone #f)
			    ;; (strace unfinished :pid 10084 :call clone)
			    ;; (strace resumed :pid 10084 :call #f :args "child_stack=0xb28fd4a4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tidptr=0xb28fdbd8, {entry_number:6, base_addr:0xb28fdb90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb28fdbd8" :xargs #f :rvalue 10095 :errno #f)
			    ;; (strace trace :pid 10070 :call clone :args "child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7f88708" :xargs (child_stack=0 |flags=CLONE_CHILD_CLEARTID\|CLONE_CHILD_SETTID\|SIGCHLD| child_tidptr=0xb7f88708) :rvalue 10071 :errno #f)
			    ;;
			    (let1 pproc (hash-table-get proc-table pid #f)
			      (when pproc
				(let1 child-pid (and-let* ((rvalue (memq :rvalue r)))
						  (cadr rvalue))
				  (if child-pid
				      (case type
					('trace
					 (slot-push! pproc 'children  child-pid)
					 (hash-table-put! proc-table
							  child-pid
							  (make <process> :pid child-pid :ppid pid)
							  ))
					('resumed
					 (unless (null? (ref pproc 'unfinished))
					   (let1 proc (slot-pop! pproc 'unfinished)
					     (slot-push! pproc 'children  child-pid)
					     (set! (ref proc 'pid) child-pid)
					     (hash-table-put! proc-table
							      child-pid
							      proc
							  ))))
					(else
					 (error "Bug<0>")))
				      (slot-push! pproc 'unfinished (make <process> :pid #f :ppid pid))))))))
			 (loop (read) proc-table signal-count)))
		      ('signaled
		       (let* ((pid (cadr (memq :pid r)))
			      (signal (list (cadr (memq :signal r))
					    (cadr (memq :deception r))))
			      (proc (hash-table-get proc-table pid #f)))
			 (set! (ref  proc 'signaled)
			       signal)
			 (set! (ref  proc 'signal-order)
			       signal-count)
			 (loop (read) proc-table (+ signal-count 1))))
		      ('killed
		       (let* ((pid (cadr (memq :pid r)))
			      (signal (list (cadr (memq :signal r))
					    (symbol->string (cadr (memq :signal r)))))
			      (proc (hash-table-get proc-table pid #f)))
			 (set! (ref  proc 'signaled)
			       signal)
			 (set! (ref  proc 'signal-order)
			       signal-count)
			 (loop (read) proc-table (+ signal-count 1)))
		       )
		      (else
		       (loop (read) proc-table (+ signal-count 1))
		       )))
		(loop (read) proc-table signal-count))))

    (format #t "digraph clone_execve {\n")
    (format #t "	graph[mindist=0.5,splines=true];\n")
    (format #t "	node[fontsize=7,shape=rect];\n")
    (for-each (lambda (v)
		(when (and (ref v 'signaled)
			 (not (eq? 'CHLD (car (ref v 'signaled)))))
		  (format #t "	\"~a\"[fontsize=7,color=red];\n"
			  (ref v 'pid)
			)))
	      (hash-table-values proc-table))    
    (for-each (lambda (v)
		(format #t "	~a[label=\"~a\\n~a~a\"];\n"
			(ref v 'pid)
			(ref v 'pid)
			(if (string? (ref v 'cmdline)) (ref v 'cmdline) "")
			(if (and (ref v 'signaled)
				 (not (eq? 'CHLD (car (ref v 'signaled)))))
			    (format "\\n(~d)~a" 
				    ;(car (ref v 'signaled))
				    (ref v 'signal-order)
				    (cadr (ref v 'signaled)))
			    (format "\\n~a"
				    (ref v 'status))
			    )
			))
	      (hash-table-values proc-table))
    (for-each (lambda (p)
		(for-each (lambda (c)
			    (format #t "	~d->~d;\n"
				    (ref p 'pid)
				    c)
			    )
			  (ref p 'children)))
	      (hash-table-values proc-table))
    #;(let1 signaled (hash-table-fold proc-table 
				    (lambda (k v r)
				      (if (ref v 'signaled)
					  (cons v r)
					  r)
				      )
				    (list))
      
      (when #f
	(format #t "\n	\n")
	(for-each (lambda (v)
		    (format #t "~a" (if (string? v) v (ref v 'pid))))
		  (intersperse "->" (sort signaled (lambda (a b)
						     (< (ref a 'signal-order)
							(ref b 'signal-order))))))
	(format #t "[color=red];\n"))
      )
    (format #t "}\n")
    ))
