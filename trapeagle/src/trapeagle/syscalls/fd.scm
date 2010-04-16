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
	  (fd-for kernel pid fd file)
	  ))))
  :unfinished
  (lambda (kernel pid resumed? time index)
    )
  :resumed
  (lambda (kernel pid xargs xrvalue xerrno unfinished? time index)
    (let1 fd (car xrvalue)
      (when (>= fd 0)
	(let1 file (make <file> 
		     :open-info (vector index index time time xargs xrvalue xerrno)
		     :unfinished? unfinished?)
	  (fd-for kernel pid fd file)
	  )))))

(defsyscall dup2
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (when (>= (car xrvalue) 0)
      (let ((old (ref xargs 0))
	    (new (ref xargs 1)))
	(let1 file (or #?=(fd-for kernel pid #?=old) (make <fd>))
	      (fd-for kernel pid new file)))))
  :unfinished
  (lambda (kernel pid resumed? time index)
    #?=index)
  :resumed
  (lambda (kernel pid xargs xrvalue xerrno unfinished? time index)
    (when (>= (car xrvalue) 0)
      (let ((old (ref xargs 0))
	    (new (ref xargs 1)))
	(let1 file (or #?=(fd-for kernel pid #?=old) (make <fd>))
	  (fd-for kernel pid new file))))
    ))

(defsyscall close
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (let1 successful? (car xrvalue)
      (when (eq? successful? 0)
	(let* ((fd (car xargs))
	       (fd-obj (fd-for kernel pid fd)))
	  (when fd-obj
	    (set! (ref fd-obj 'closed?) (list (list index time) (list index time)))))
	)))
  :unfinished
  (lambda (kernel pid resumed? time index)
    )
  :resumed
  (lambda (kernel pid xargs xrvalue xerrno unfinished? time index)
    (let1 successful? (car xrvalue)
      (when (eq? successful? 0)
	(let* ((fd (car xargs))
	       (fd-obj (fd-for kernel pid fd)))
	  (when fd-obj
	    ;; --------------------------------------------VTODO
	    (set! (ref fd-obj 'closed?) (list (list unfinished? #f) (list index time))))))
	)))


(defsyscall socket
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (let* ((fd (car xrvalue))
	   (successful? (>= fd 0)))
      (when successful?
	(let1 socket (make <socket>
		       :socket-info xargs
		       :unfinished? #f)
	  (fd-for kernel pid fd socket)))))
  :resumed
  (lambda (kernel pid xargs xrvalue xerrno unfinished? time index)
    (let* ((fd (car xrvalue))
	   (successful? (>= fd 0)))
      (when successful?
	(let1 socket (make <socket>
		       :socket-info xargs
		       :unfinished? unfinished?)
	  (fd-for kernel pid fd socket)))))
  )

(defsyscall accept
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    
    )
  )


(defsyscall shutdown
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (let1 successful? (car xrvalue)
      (when (eq? successful? 0)
	(let* ((fd (car xargs))
	       (fd-obj (fd-for kernel pid fd))
	       (how (ref xargs 1))
	       (current (ref fd-obj 'closed?)))
	  (when fd-obj
	    (set! (ref fd-obj 'closed?) (list 
					 (or (ref current 0)
					     (cond
					      ((or (eq? how 'SHUT_RD)
						   (eq? how 'SHUT_RDWR))
					       (list index time))
					      (else
					       #f)))
					 (or (ref current 1)
					    (cond
					     ((or (eq? how 'SHUT_WR)
						  (eq? how 'SHUT_RDWR))
					      (list index time))
					     (else
					      #f))))))))))
  :resumed
  (lambda (kernel pid xargs xrvalue xerrno unfinished? time index)
    (when (eq? successful? 0)
	(let* ((fd (car xargs))
	       (fd-obj (fd-for kernel pid fd))
	       (how (ref xargs 1))
	       (current (ref fd-obj 'closed?)))
	  (when fd-obj
	    (set! (ref fd-obj 'closed?) (list 
					 (or (ref current 0)
					     (cond
					      ((or (eq? how 'SHUT_RD)
						   (eq? how 'SHUT_RDWR))
					       (list unfinished? #f))
					      (else
					       #f)))
					 (or (ref current 1)
					    (cond
					     ((or (eq? how 'SHUT_WR)
						  (eq? how 'SHUT_RDWR))
					      (list index time))
					     (else
					      #f))))))))))

(provide "trapeagle/syscalls/fd")