(define-module trapeagle.report
  (export report)
  (use trapeagle.resource)
  (use srfi-1)
  )

(select-module trapeagle.report)

(define-method report ((task <task>))
  (format #t "ptid: ~s\n" (ref task 'parent-tid))
  (format #t "tid: ~s\n" (ref task 'tid))
  (format #t "exit-info: ~s\n" (ref task 'exit-info))
  (format #t "children: ~s\n" 
	  (map 
	   (lambda (child) (ref child 'tid))
	   (sort (filter (complement dead?) (children-of task))
		 (lambda (a b) (< (ref a 'tid) (ref b 'tid))))))
  )

(define-method report ((process <process>))
  (next-method)
  (format #t "execve: ~s\n" (ref process 'execve-info))
  (let1 fds (let1 table (ref process 'fd-table)
	      (map
	       (lambda (fd) (cons fd (ref table fd)))
	       (sort (hash-table-keys table) <)))
    (format #t "fd-tables: ~s\n" (map car fds))
    (for-each (lambda (elt) 
		(when (let1 closed? (ref (cdr elt) 'closed?)
			(or (not (car closed?)) (not (cadr closed?))))
		  (format #t "fd: ~s\n" (car elt))
		  (report (cdr elt))))
	      fds)))

(define-method report ((fd <fd>))
  (format #t "unfinished: ~s\n" (ref fd 'unfinished?))
  (format #t "closed?: ~s\n" (ref fd 'closed?))
  )
(define-method report ((file <file>))
  (format #t "open-info: ~s\n" (ref file 'open-info))
  (next-method))

(define-method report ((file <socket>))
  (format #t "socket-info: ~s\n" (ref file 'socket-info))
  (next-method))

(define-method report ((file <request-socket>))
  (format #t "accept-info: ~s\n" (ref file 'accept-info))
  (next-method))

(provide "trapeagle/report")