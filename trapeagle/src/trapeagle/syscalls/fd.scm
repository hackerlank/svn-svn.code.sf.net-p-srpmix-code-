(define-module trapeagle.syscalls.fd
  (use trapeagle.type)
  (use trapeagle.syscall)
  (use trapeagle.resource)
  (use trapeagle.linux)
  (use trapeagle.call-info)
  )

(select-module trapeagle.syscalls.fd)

(defsyscall open
  :trace 
  (lambda* (kernel pid xargs xrvalue xerrno time index)
	   (let1 fd (car xrvalue)
	     (when (>= fd 0)
	       (let1 file (make <file>)
		 (fd-for kernel pid fd file)
		 (update-info! file 'open-info 'trace 'open $)
		 ))))
  :unfinished
  (lambda* (kernel pid resumed? time index)
	   (update-info! #f 'open-info 'unfinished 'open $))
  :resumed
  (lambda* (kernel pid xargs xrvalue xerrno unfinished? time index)
	   (let1 fd (car xrvalue)
	     (if (>= fd 0)
		 (let1 file (make <file>)
		   (fd-for kernel pid fd file)
		   (update-info! file 'open-info 'resumed 'open $))
		 (clear-unfinished-syscall! kernel pid)))))

(defsyscall dup2
  :trace
  (lambda* (kernel pid xargs xrvalue xerrno time index)
    (when (>= (car xrvalue) 0)
      (let ((old (ref xargs 0))
	    (new (ref xargs 1)))
	(let1 file (or (fd-for kernel pid old) (make <fd>))
	  (fd-for kernel pid new file)
	  (update-info! file 'open-info 'trace 'dup2 $)
	  ))))
  :unfinished
  (lambda* (kernel pid resumed? time index)
	   (update-info! file 'open-info 'unfinished 'dup2 $))
  :resumed
  (lambda* (kernel pid xargs xrvalue xerrno unfinished? time index)
    (when (>= (car xrvalue) 0)
      (let ((old (ref xargs 0))
	    (new (ref xargs 1)))
	(let1 file (or (fd-for kernel pid old) (make <fd>))
	  (fd-for kernel pid new file)
	  (update-info! file 'open-info 'resumed 'dup2 $)
	  )))
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
  (lambda* (kernel pid xargs xrvalue xerrno time index)
	   (let1 fd (car xrvalue)
	     (when (>= fd 0)
	       (let1 file (make <socket>)
		 (fd-for kernel pid fd file)
		 (update-info! file 'open-info 'trace 'socket $)
		 ))))
  :unfinished
  (lambda* (kernel pid resumed? time index)
	   (update-info! #f 'open-info 'unfinished 'socket $))
  :resumed
  (lambda* (kernel pid xargs xrvalue xerrno unfinished? time index)
	   (let1 fd (car xrvalue)
	     (if (>= fd 0)
		 (let1 file (make <socket>)
		   (fd-for kernel pid fd file)
		   (update-info! file 'open-info 'resumed 'socket $))
		 (clear-unfinished-syscall! kernel pid)))))

(defsyscall accept
  :trace
  (lambda* (kernel pid xargs xrvalue xerrno time index)
	   (let* ((fd (car xrvalue))
		  (successful? (>= fd 0)))
	     (when successful?
	       (let1 file (make <request-socket>)
		 (fd-for kernel pid fd file)
		 (update-info! file 'open-info 'trace 'accept $)
		 ))))
  :unfinished
  (lambda* (kernel pid resumed? time index)
	   (update-info! #f 'open-info 'unfinished 'accept $))
  :resumed
  (lambda* (kernel pid xargs xrvalue xerrno unfinished? time index)
	   (let1 fd (car xrvalue)
	     (if (>= fd 0)
		 (let1 file (make <request-socket>)
		   (fd-for kernel pid fd file)
		   (update-info! file 'open-info 'resumed 'accept $))
		 (clear-unfinished-syscall! kernel pid)))))

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

(defsyscall bind
  :trace
  (lambda* (kernel pid xargs xrvalue xerrno time index)
	   (let1 socket (fd-for kernel pid (car xargs))
	     (update-info! socket 'bind-info 'trace 'bind $)))
  :unfinished
  (lambda* (kernel pid resumed? time index)
	   (let1 socket (fd-for kernel pid (car xargs))
	     (update-info! socket 'bind-info 'unfinished 'bind $)))
  :resumed
  (lambda* (kernel pid xargs xrvalue xerrno unfinished? time index)
	   (let1 socket (fd-for kernel pid (car xargs))
	     (update-info! socket 'bind-info 'resumed 'bind $))))

(defsyscall listen
  :trace
  (lambda* (kernel pid xargs xrvalue xerrno time index)
	   (let1 socket (fd-for kernel pid (car xargs))
	     (update-info! socket 'listen-info 'trace 'listen $)))
  :unfinished
  (lambda* (kernel pid resumed? time index)
	   (let1 socket (fd-for kernel pid (car xargs))
	     (update-info! socket 'listen-info 'unfinished 'listen $)))
  :resumed
  (lambda* (kernel pid xargs xrvalue xerrno unfinished? time index)
	   (let1 socket (fd-for kernel pid (car xargs))
	     (update-info! socket 'listen-info 'resumed 'listen $))))

(defsyscall connect
  :trace
  (lambda* (kernel pid xargs xrvalue xerrno time index)
	   (let1 socket (fd-for kernel pid (car xargs))
	     (update-info! socket 'connect-info 'trace 'connect $)))
  :unfinished
  (lambda* (kernel pid resumed? time index)
	   (let1 socket (fd-for kernel pid (car xargs))
	     (update-info! socket 'connect-info 'unfinished 'connect $)))
  :resumed
  (lambda* (kernel pid xargs xrvalue xerrno unfinished? time index)
	   (let1 socket (fd-for kernel pid (car xargs))
	     (update-info! socket 'connect-info 'resumed 'connect $))))

(provide "trapeagle/syscalls/fd")