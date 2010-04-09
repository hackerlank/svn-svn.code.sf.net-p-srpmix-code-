(define-module trapeagle.syscalls.task
  (use trapeagle.type)
  (use trapeagle.syscall)
  (use trapeagle.resource)
  (use trapeagle.linux)
  )

(select-module trapeagle.syscalls.task)

(defsyscall clone
  :trace 
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (define thread? (memq 'CLONE_VM (cadr xargs)))
    (define born? (> (car xrvalue) 0))
    (when born?
      (let ((ppid pid)
	    (pid (car xrvalue)))
	(let* ((parent (get-task kernel ppid))
	       (child (if thread?
			  (make <task> 
			    :parent-tid ppid
			    :tid pid
			    :clone-info (vector index index time time xargs xrvalue xerrno)
			    :fd-table (ref parent 'fd-table))
			  (make <process>
			    :parent-tid ppid
			    :tid pid
			    :clone-info (vector index index time time xargs xrvalue xerrno)
			    ;; TODO COPY
			    ))))
	  ;; Check overlaypping
	    (hash-table-put! (ref kernel 'task-table) pid child)
	    (push! (ref parent 'children) child)
	    ))))
  :unfinished
  (lambda (kernel pid resumed? time index)
    #f))

(defsyscall execve
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (when (eq? xrvalue 0)
      (let1 task (get-task kernel pid)
	(set! (ref task 'execve-info) (vector index index time time xargs xrvalue xerrno))))))

(provide "trapeagle/syscalls/task")