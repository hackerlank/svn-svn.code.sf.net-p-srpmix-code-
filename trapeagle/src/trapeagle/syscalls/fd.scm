(define-module trapeagle.syscalls.fd
  (use trapeagle.type)
  (use trapeagle.syscall)
  (use trapeagle.resource)
  (use trapeagle.linux)
  )

(select-module trapeagle.syscalls.fd)

(defsyscall open
  :trace 
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (let1 fd (car xrvalue)
      (when (>= fd 0)
	(let1 file (make <file> 
		     :open-info (vector index index time time xargs xrvalue xerrno)
		     :unfinished? #f)
	  (hash-table-put! (ref (get-task kernel pid) 'fd-table) fd file) 
	  ))))
  :unfinished
  (lambda (kernel pid resumed? time index)
    #f)
  )

(defsyscall close
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (let1 successful? (car xrvalue)
      (when (eq? successful? 0)
	(let* ((fd (car xargs))
	       (fd-obj (ref (ref (get-task kernel pid) 'fd-table) fd #f)))
	  (when fd-obj
	    (set! (ref fd-obj 'closed?) (list (list index time) (list index time)))))
	))))

(defsyscall socket
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    #f)
  )

(provide "trapeagle/syscalls/fd")