(define-module trapeagle.report
  (export report)
  (use trapeagle.resource)
  (use srfi-1)
  )

(select-module trapeagle.report)

(define-method report ((task <task>) filter-args)
  (let1 condition (if (memq 'alive-only filter-args)
		      (complement dead?)
		      boolean)
    (format #t "parent-tid: ~s\n" (ref task 'parent-tid))
    (format #t "tid: ~s\n" (ref task 'tid))
    (format #t "clone-info: ~s\n" (ref task 'clone-info))
    (format #t "execve-info: ~s\n" (ref task 'execve-info))
    (format #t "exit-info: ~s\n" (ref task 'exit-info))
    (format #t "unfinished-syscall: ~s\n" (ref task 'unfinished-syscall))
    (format #t "children: ~s\n" 
	    (map 
	     (lambda (child) (ref child 'tid))
	     (sort (filter condition (children-of task))
		   (lambda (a b) (< (ref a 'tid) (ref b 'tid))))))
    ))

(define-method report ((process <process>) filter)
  (next-method)
  (let ((condition (if (memq 'alive-only filter)
		       (complement closed?)
		       boolean))
	(fds (let1 table (ref process 'fd-table)
	       (map
		(lambda (fd) (cons fd (ref table fd)))
		(sort (hash-table-keys table) <)))))
    (format #t "fd-tables: ~s\n" (map car fds))
    (for-each (lambda (elt) 
		(when (condition (cdr elt))
		  (format #t "<~d>fd: ~s\n" (ref process 'tid) (car elt))
		  (report (cdr elt) 
			  (format "<~d>" (ref process 'tid))
			  filter)))
	      fds)))

(define-method report ((fd <fd>) prefix filter)
  (format #t "~aopen-info: ~s\n" prefix (ref fd 'open-info))
  (format #t "~aunfinished-syscall: ~s\n" prefix (ref fd 'unfinished-syscall))
  (format #t "~aclosed?: ~s\n" prefix (closed? fd))
  (format #t "~aasync?: ~s\n" prefix (async? fd)))

(define-method report ((file <file>) prefix filter)
  (next-method))

(define-method report ((socket <socket>) prefix filter)
  (next-method)
  (format #t "~abind-info: ~s\n" prefix (ref socket 'bind-info))
  (format #t "~alisten-info: ~s\n" prefix (ref socket 'listen-info))
  (format #t "~aconnect-info: ~s\n" prefix (ref socket 'connect-info))
  )

(define-method report ((file <request-socket>) prefix filter)
  (next-method))

(provide "trapeagle/report")