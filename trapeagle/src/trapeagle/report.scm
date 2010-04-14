(define-module trapeagle.report
  (export report)
  (use trapeagle.resource))

(select-module trapeagle.report)

(define-method report ((task <task>))
  (format #t "ptid: ~s\n" (ref task 'parent-tid))
  (format #t "tid: ~s\n" (ref task 'tid))
  (format #t "children: ~s\n" 
	  (map 
	   (lambda (child) (ref child 'tid))
	   (sort (ref task 'children) 
		 (lambda (a b) (< (ref a 'tid) (ref b 'tid)))))))

(define-method report ((process <process>))
  (next-method)
  (format #t "execve: ~s\n" (ref process 'execve-info))
  (for-each (lambda (elt) 
	      (format #t "fd: ~s\n" (car elt))
	      (report (cdr elt)))
	    (let1 table (ref process 'fd-table)
	      (map
	       (lambda (fd) (cons fd (ref table fd)))
	       (sort (hash-table-keys table) <)))))

(define-method report ((fd <fd>))
  (format #t "unfinished: ~s\n" (ref fd 'unfinished?))
  (format #t "closed?: ~s\n" (ref fd 'closed?))
  )
(define-method report ((file <file>))
  (format #t "open-info: ~s\n" (ref file 'open-info))
  (next-method))

(provide "trapeagle/report")