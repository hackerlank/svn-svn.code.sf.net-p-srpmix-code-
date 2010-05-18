;; (put 'lambda* 'scheme-indent-function 1)
(define-module trapeagle.syscalls.fd
  (use trapeagle.type)
  (use trapeagle.syscall)
  (use trapeagle.resource)
  (use trapeagle.linux)
  (use trapeagle.call-info)
  (use trapeagle.clone)
  )

(select-module trapeagle.syscalls.fd)

(defsyscall open
  :trace 
  (lambda* (kernel pid call xargs xrvalue xerrno time index)
    (let1 fd (car xrvalue)
      (when (>= fd 0)
	(let1 file (make <file>)
	  (fd-for kernel pid fd file)
	  (update-info! file 'open-info 'trace $)
	  ))))
  :unfinished
  (lambda* (kernel pid call xargs xrvalue xerrno resumed? time index)
    (update-info! #f 'open-info 'unfinished $))
  :resumed
  (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (let1 fd (car xrvalue)
      (if (>= fd 0)
	  (let1 file (make <file>)
	    (fd-for kernel pid fd file)
	    (update-info! file 'open-info 'resumed $))
	  (clear-unfinished-syscall! kernel pid)))))

;; close
(defsyscall dup2
  :trace
  (lambda* (kernel pid call xargs xrvalue xerrno time index)
    (when (>= (car xrvalue) 0)
      (let ((old (ref xargs 0))
	    (new (ref xargs 1)))
	(let* ((new-file (or (clone (fd-for kernel pid old)) (make <fd>)))
	       (old-file (or (fd-for kernel pid old) (make <fd>))))
	  (fd-for kernel pid new new-file)
	  (update-info! new-file 'open-info 'trace $ 
			:record-history #t)
	  (update-info! old-file 'close-info 'trace $)
	  ))))
  :unfinished
  (lambda* (kernel pid call xargs xrvalue xerrno resumed? time index)
    (update-info! #f 'open-info 'unfinished $))
  :resumed
  (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (when (>= (car xrvalue) 0)
      (let ((old (ref xargs 0))
	    (new (ref xargs 1)))
	(let* ((new-file (or (clone (fd-for kernel pid old)) (make <fd>)))
	       (old-file (or (fd-for kernel pid old) (make <fd>))))
	  (fd-for kernel pid new new-file)
	  (update-info! new-file 'open-info 'resumed $
			:record-history #t)
	  (update-info! old-file 'close-info 'resumed $)
	  ))
      (clear-unfinished-syscall! kernel pid))))

(defsyscall close
  :trace
  (lambda* (kernel pid call xargs xrvalue xerrno time index)
    (let1 successful? (eq? (car xrvalue) 0)
      (when successful?
	(let* ((fd (car xargs))
	       (file (or (fd-for kernel pid fd) (make <fd>))))
	  (update-info! file 'close-info 'trace $)
	  ))))
  :unfinished
  (lambda* (kernel pid call xargs xrvalue xerrno resumed? time index)
    (update-info! #f 'close-info 'unfinished $))
  :resumed
  (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (let1 successful? (eq? (car xrvalue) 0)
      (when successful?
	(let* ((fd (car xargs))
	       (file (or (fd-for kernel pid fd) (make <fd>))))
	  (update-info! file 'close-info 'resumed $)
	  )
	(clear-unfinished-syscall! kernel pid)))))

(defsyscall socket
  :trace
  (lambda* (kernel pid call xargs xrvalue xerrno time index)
    (let* ((fd (car xrvalue))
	   (successful? (>= fd 0)))
      (when successful?
	(let1 socket (make <socket>)
	  (fd-for kernel pid fd socket)
	  (update-info! socket 'open-info 'trace $)))))
  :unfinished
  (lambda* (kernel pid call xargs xrvalue xerrno resumed? time index)
    (update-info! #f 'open-info 'unfinished $))
  :resumed
  (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (let* ((fd (car xrvalue))
	   (successful? (>= fd 0)))
      (when successful?
	(let1 file (make <socket>)
	  (fd-for kernel pid fd file)
	  (update-info! file 'open-info 'resumed $)))
      (clear-unfinished-syscall! kernel pid))))

(defsyscall accept
  :trace
  (lambda* (kernel pid call xargs xrvalue xerrno time index)
    (let* ((fd (car xrvalue))
	   (successful? (>= fd 0)))
      (when successful?
	(let1 socket (make <request-socket>)
	  (fd-for kernel pid fd socket)
	  (update-info! socket 'open-info 'trace $)
	  ))))
  :unfinished
  (lambda* (kernel pid call xargs xrvalue xerrno resumed? time index)
    (update-info! #f 'open-info 'unfinished $))
  :resumed
  (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (let1 fd (car xrvalue)
      (when (>= fd 0)
	(let1 socket (make <request-socket>)
	  (fd-for kernel pid fd socket)
	  (update-info! socket 'open-info 'resumed $))))
    (clear-unfinished-syscall! kernel pid)))


(defsyscall shutdown
  :trace
  (lambda* (kernel pid call xargs xrvalue xerrno time index)
    (let1 successful? (eq? (car xrvalue) 0)
      (when successful?
	(let* ((fd (car xargs))
	       (socket (or (fd-for kernel pid fd) (make <fd>)))
	       (how (ref xargs 1)))
	  (when (or (eq? how 'SHUT_RD) (eq? how 'SHUT_RDWR))
	    (update-info! socket 'input-shutdown-info 'trace $))
	  (when (or (eq? how 'SHUT_WR) (eq? how 'SHUT_RDWR))
	    (update-info! socket 'output-shutdown-info 'trace $))))))
  :unfinished
  (lambda* (kernel pid call xargs xrvalue xerrno  resumed? time index)
    (update-info #f 'input-shutdown-info 'unfinished $)
    (update-info #f 'output-shutdown-info 'unfinished $))
  :resumed
  (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (let1 successful? (eq? (car xrvalue) 0)
      (when successful?
	(let* ((fd (car xargs))
	       (socket (or (fd-for kernel pid fd) (make <fd>)))
	       (how (ref xargs 1)))
	  (when (or (eq? how 'SHUT_RD) (eq? how 'SHUT_RDWR))
	    (update-info! socket 'input-shutdown-info 'resumed $))
	  (when (or (eq? how 'SHUT_WR) (eq? how 'SHUT_RDWR))
	    (update-info! socket 'output-shutdown-info 'resumed $))))
      (clear-unfinished-syscall! kernel pid))))

;; TODO: F_DUPFD, F_DUPFD_CLOEXEC
(defsyscall fcntl
  :trace
  (lambda* (kernel pid call xargs xrvalue xerrno time index)
    (let1 successful? (or (symbol? (car xrvalue))
			  (>= (car xrvalue) 0))
      (when successful?
	(let* ((fd (car xargs))
	       (cmd (cadr xargs))
	       (file (or (fd-for kernel pid fd) (make <fd>))))
	  (case cmd
	    ('F_GETFD
	     (when (and-let* ((flags (cdr xrvalue))
			      ((not (null? flags))))
		     (memq 'FD_CLOEXEC (cdar flags)))
	       (set! (ref file 'close-on-exec?) #t)))
	    ('F_SETFD
	     (when (eq? 'FD_CLOEXEC (caddr xargs))
	       (set! (ref file 'close-on-exec?) #t))))))))
  :resumed
  (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (let1 successful? (or (symbol? (car xrvalue))
			  (>= (car xrvalue) 0))
      (when successful?
	(let* ((fd (car xargs))
	       (cmd (cadr xargs))
	       (file (or (fd-for kernel pid fd) (make <fd>))))
	  (case cmd
	    ('F_GETFD
	     (when (and-let* ((flags (cdr xrvalue))
			      ((not (null? flags))))
		     (memq 'FD_CLOEXEC (cdar flags)))
	       (set! (ref file 'close-on-exec?) #t)))
	    ('F_SETFD
	     (when (eq? 'FD_CLOEXEC (caddr xargs))
	       (set! (ref file 'close-on-exec?) #t)))))))))

(defsyscall bind
  :trace
  (lambda* (kernel pid call xargs xrvalue xerrno time index)
    (let1 socket (fd-for kernel pid (car xargs))
      (update-info! socket 'bind-info 'trace $)))
  :unfinished
  (lambda* (kernel pid call xargs xrvalue xerrno resumed? time index)
    (update-info! #f 'bind-info 'unfinished $))
  :resumed
  (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (let1 socket (fd-for kernel pid (car xargs))
      (update-info! socket 'bind-info 'resumed $))
    (clear-unfinished-syscall! kernel pid)))

(defsyscall listen
  :trace
  (lambda* (kernel pid call xargs xrvalue xerrno time index)
    (let1 socket (fd-for kernel pid (car xargs))
      (update-info! socket 'listen-info 'trace $)))
  :unfinished
  (lambda* (kernel pid call xargs xrvalue xerrno resumed? time index)
    (update-info! #f 'listen-info 'unfinished $))
  :resumed
  (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (let1 socket (fd-for kernel pid (car xargs))
      (update-info! socket 'listen-info 'resumed $))
    (clear-unfinished-syscall! kernel pid)))

(defsyscall connect
  :trace
  (lambda* (kernel pid call xargs xrvalue xerrno time index)
    (let1 socket (fd-for kernel pid (car xargs))
      (update-info! socket 'connect-info 'trace $)))
  :unfinished
  (lambda* (kernel pid call xargs xrvalue xerrno resumed? time index)
    (update-info! #f 'connect-info 'unfinished $))
  :resumed
  (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (let1 socket (fd-for kernel pid (car xargs))
      (update-info! socket 'connect-info 'resumed $))
    (clear-unfinished-syscall! kernel pid)))

;; socket(SCM_RIGHTS)
(define (set-non-block! kernel pid xargs xrvalue xerrno index)
  (cond
   ((and (eq? (cadr xargs) 'F_SETFL)
	 (eq? (car xrvalue) 0))
    (when (memq 'O_NONBLOCK (caddr xargs))
      (let1 fd (fd-for kernel pid (car xargs))
	(set! (ref fd 'async?) index))))
   ((and (eq? (cadr xargs) 'F_GETFL)
	 (not xerrno))
    (when (memq 'O_NONBLOCK (cadr xrvalue))
      (let1 fd (fd-for kernel pid (car xargs))
	(unless (ref fd 'async?)
	  (set! (ref fd 'async?) index)))))))

(defsyscall fcntl64
  :trace
  (lambda (kernel pid call xargs xrvalue xerrno time index)
    (set-non-block! kernel pid xargs xrvalue xerrno index))
  :unfinished
  (lambda (kernel pid call xargs xrvalue xerrno resumed? time index)
    (set-unfinished-syscall! kernel pid resumed? time index)
    )
  :resumed
  (lambda (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (clear-unfinished-syscall! kernel pid)
    (set-non-block! kernel pid xargs xrvalue xerrno index)))

(defsyscall pipe
  :trace
  (lambda* (kernel pid call xargs xrvalue xerrno time index)
    (let* ((r (car xrvalue))
	   (successful? (eq? r 0)))
      (when successful?
	(let ((pipe0 (make <pipe>))
	      (pipe1 (make <pipe>))
	      (pfd0 (ref (car xargs) 1))
	      (pfd1 (ref (car xargs) 2)))
	  (fd-for kernel pid pfd0 pipe0)
	  (fd-for kernel pid pfd1 pipe1)
	  (update-info! pipe0 'open-info 'trace $)
	  (update-info! pipe1 'open-info 'trace $)
	  (set! (ref pipe0 'peer) pipe1)
	  (set! (ref pipe1 'peer) pipe0)
	  ))))
  :unfinished
  (lambda* (kernel pid call xargs xrvalue xerrno resumed? time index)
    (update-info! #f 'open-info 'unfinished $))
  :resumed
  (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (let* ((r (car xrvalue))
	   (successful? (eq? r 0)))
      (when successful?
	(let ((pipe0 (make <pipe>))
	      (pipe1 (make <pipe>))
	      (pfd0 (ref (car xargs) 1))
	      (pfd1 (ref (car xargs) 2)))
	  (fd-for kernel pid pfd0 pipe0)
	  (fd-for kernel pid pfd1 pipe1)
	  (update-info! pipe0 'open-info 'resumed $)
	  (update-info! pipe1 'open-info 'resumed $)
	  (set! (ref pipe0 'peer) pipe1)
	  (set! (ref pipe1 'peer) pipe0)
	  ))
      (clear-unfinished-syscall! kernel pid)))
  )
  
(provide "trapeagle/syscalls/fd")