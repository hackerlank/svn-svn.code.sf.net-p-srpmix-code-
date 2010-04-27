(define-module trapeagle.syscalls.task
  (use trapeagle.type)
  (use trapeagle.syscall)
  (use trapeagle.resource)
  (use trapeagle.linux)
  (use trapeagle.clone)
  (use trapeagle.call-info)
  )

(select-module trapeagle.syscalls.task)

(defsyscall clone
  :trace 
  (lambda* (kernel pid xargs xrvalue xerrno time index)
    (define thread? (memq 'CLONE_VM (cdadr (cadr xargs))))
    (define born? (> (car xrvalue) 0))
    (when born?
      (let ((ppid pid)
	    (pid (car xrvalue)))
	(let* ((parent (task-for kernel ppid))
	       (child (if thread?
			  (make <task> 
			    :parent-tid ppid
			    :tid pid
			    :fd-table (ref parent 'fd-table))
			  (make <process>
			    :parent-tid ppid
			    :tid pid
			    :fd-table (clone (ref parent 'fd-table))
			    ))))
	  (update-info! child 'clone-info 'trace 'clone $)
	  ;; Check overlaypping
	    (hash-table-put! (ref kernel 'task-table) pid child)
	    (push! (ref parent 'children) child)
	    ))))
  :unfinished
  (lambda (kernel pid resumed? time index)
    #f))

(define-method for-each-close-on-exec-fds ((task <task>)
					   proc)
  (let1 fd-table (ref task 'fd-table)
    (for-each
     (lambda (fd) 
       (let1 file (ref fd-table fd)
	 (when (ref file 'close-on-exec?)
	   (proc file)
	   )))
     (hash-table-keys fd-table))))

(defsyscall execve
  :trace
  (lambda* (kernel pid xargs xrvalue xerrno time index)
    (when (eq? (car xrvalue) 0)
      (let1 task (task-for kernel pid)
	(update-info! task 'execve-info 'trace 'execve $)
	(for-each-close-on-exec-fds 
	 task
	 (lambda (file)
	   (update-info! file 'input-close-info 'trace 'execve $)
	   (update-info! file 'output-close-info 'trace 'execve $)))
	)))
  :unfinished
  (lambda* (kernel pid resumed? time index)
    (update-info! (task-for kernel pid) 'execve-info 'unfinished 'execve $))
  :resumed
  (lambda* (kernel pid xargs xrvalue xerrno unfinished? time index)
    (if (eq? (car xrvalue) 0)
	(let1 task (task-for kernel pid)
	  (update-info! task 'execve-info 'resumed 'execve $)
	  (for-each-close-on-exec-fds 
	   task
	   (lambda (file)
	     (update-info! file 'input-close-info 'trace 'execve $)
	     (update-info! file 'output-close-info 'trace 'execve $))))
	(clear-unfinished-syscall! kernel pid))))

(defsyscall exit_group
  :trace
  (lambda* (kernel pid xargs xrvalue xerrno time index)
    (let1 task (task-for kernel pid)
      (update-info! task 'exit-info 'trace 'exit_group $)
      (for-each
       (lambda (child)
	 ;; TODO: Check this condition
	 (unless (eq? (ref task 'fd-table) (ref child 'fd-table))
	   (update-info! child 'exit-info 'trace 'exit_group $)))
       (children-of task))))
  ;; TODO unfinished, resumed
  )

(defsyscall _exit
  :trace
  (lambda* (kernel pid xargs xrvalue xerrno time index)
    (let1 task (task-for kernel pid)
      (update-info! task 'exit-info 'trace '_exit $)
      )))

(provide "trapeagle/syscalls/task")