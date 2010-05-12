(define-module trapeagle.linux
  (export <linux>
	  report
	  task-for
	  fd-for)
  (use trapeagle.type)
  (use trapeagle.resource)
  )

(select-module trapeagle.linux)

(define-class <linux> ()
  ((init-task)
   (task-table :init-value (make-hash-table 'eq?))
   ))

(define-method init-task ((kernel <linux>) pid)
  (set! (ref kernel 'init-task)
	(make <process> 
	  :parent-tid #f
	  :tid pid))
  (set! (ref (ref kernel 'task-table) pid) (ref kernel 'init-task))
  (ref kernel 'init-task))

(define-method task-for ((kernel <linux>) tid)
  (let1 task (ref (ref kernel 'task-table) tid #f)
    (if task
	task
	(init-task kernel tid))))

(define-method fd-for ((kernel <linux>) tid fd)
  (and-let* ((task (task-for kernel tid))
	     (fd-table (ref task 'fd-table))
	     (fd (ref fd-table fd #f)))
    fd))

(define-method fd-for ((kernel <linux>) 
		       tid 
		       fd
		       create-if-not-found)
  (let1 fd-obj (fd-for kernel tid fd)
    (if (and (not fd-obj) create-if-not-found)
	(let1 fd-obj (make <fd>)
	  (fd-for kernel tid fd fd-obj))
	fd-obj)))

(define-method fd-for ((kernel <linux>) tid fd (fd-obj <fd>))
  (let* ((task (task-for kernel tid))
	 (fd-table (ref task 'fd-table)))
    (hash-table-put! fd-table fd fd-obj)
    fd-obj))

(provide "trapeagle/linux")