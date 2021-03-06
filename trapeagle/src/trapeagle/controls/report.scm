(define-module trapeagle.controls.report
  (export report)
  (use trapeagle.control)
  (use trapeagle.linux)
  (use trapeagle.resource)
  (use srfi-1)
  )

(select-module trapeagle.controls.report)

(define-method report ((kernel <linux>) filter)
  (let ((table (ref kernel 'task-table))
	(condition (if (get-keyword :alive-only filter #f)
		       (complement dead?)
		       boolean)))
    (for-each
     (lambda (tid)  (let1 task (ref table tid)
		      (when (condition task)
			(report task filter))))
     (sort (hash-table-keys table) <))))

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
  (format #t "~aasync?: ~s\n" prefix (async? fd))
  (when (get-keyword :io filter #f)
    (format #t "~aio: ~s\n" prefix (io fd)))
  )

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

(defcontrol report (kernel . args) 
  "Report kernel status:
 (report [:alive-only BOOLEAN] [:io BOOLEAN])"
  (report kernel args))

(provide "trapeagle/controls/report")
