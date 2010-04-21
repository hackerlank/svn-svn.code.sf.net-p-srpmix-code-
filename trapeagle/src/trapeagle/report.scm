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
    (format #t "clone-info ~s\n" (ref task 'clone-info))
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
		  (format #t "fd: ~s\n" (car elt))
		  (report (cdr elt) filter)))
	      fds)))

(define-method report ((fd <fd>) filter)
  (format #t "open-info: ~s\n" (ref fd 'open-info))
  (format #t "unfinished-syscall: ~s\n" (ref fd 'unfinished-syscall))
  (format #t "closed?: ~s\n" (closed? fd)))

(define-method report ((file <file>) filter)
  (next-method))

(define-method report ((socket <socket>) filter)
  (next-method)
  (format #t "bind-info: ~s\n" (ref socket 'bind-info))
  (format #t "listen-info: ~s\n" (ref socket 'listen-info))
  (format #t "connect-info: ~s\n" (ref socket 'connect-info))
  )

(define-method report ((file <request-socket>) filter)
  (next-method))

(provide "trapeagle/report")