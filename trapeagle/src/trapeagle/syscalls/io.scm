(define-module trapeagle.syscalls.io
  (use trapeagle.type)
  (use trapeagle.syscall)
  (use trapeagle.resource)
  (use trapeagle.linux)
  (use trapeagle.call-info)
  (use trapeagle.clone)
  )
(select-module trapeagle.syscalls.io)

;; read, write, readable, writable...

(define-macro (defio target key)
  `(defsyscall ,target
     :trace
     (lambda* (kernel pid call xargs xrvalue xerrno time index)
       (io 
	(fd-for kernel pid (car xargs) #t) 
	(list ,key 
	      ;call
	      pid
	      xrvalue xerrno index index)))
       :unfinished
       (lambda* (kernel pid call xargs xrvalue xerrno resumed? time index)
	 (io 
	  (fd-for kernel pid (car xargs) #t)
	  (list ,key
		;call
		pid
		xrvalue xerrno index #f)))
         :resumed
	 (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
	   (io 
	    (fd-for kernel pid (car xargs) #t)
	    (list ,key 
		  ;call
		  pid
		  xrvalue xerrno #f index)))))

(defio read     'r)
(defio recv     'r)
(defio recvfrom 'r)

(defio write  'w)
(defio send   'w)
(defio sendto 'w)

(defio close 'close)
(defio shutdown 'close)			;? TODO
(defio connect 'connect)
(defio bind 'bind)
(defio accept 'accept)
(defio listen 'listen)

;(defsyscall+)
(defsyscall fcntl64
  :trace
  (lambda (kernel pid call xargs xrvalue xerrno time index)
    (when (and (eq? (cadr xargs) 'F_SETFL)
	       (eq? (car xrvalue) 0)
	       (memq 'O_NONBLOCK (caddr xargs)))
      (io 
       (fd-for kernel pid (car xargs) #t)
       (list 'nonblock pid index))))
  :resumed
  (lambda (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (when (and (eq? (cadr xargs) 'F_SETFL)
	       (eq? (car xrvalue) 0)
	       (memq 'O_NONBLOCK (caddr xargs)))
      (io 
       (fd-for kernel pid (car xargs) #t)
       (list 'nonblock pid index)))))

(define (all-fds-in-xargs xargs)
  (map 
   (lambda (struct) (cadr (cadr struct)))
   (cdr (car xargs))))

(define (all-fds-in-xrvalue xrvalue)
  (map
   (lambda (struct) 
     (cons (cadr (cadr struct))
	   (cdr (ref struct 2))
	   ))
   (cdr (cadr xrvalue))))

(defsyscall poll
  :trace
  (lambda (kernel pid call xargs xrvalue xerrno time index)
    (when (>= (car xrvalue) 0)
      (for-each
       (lambda (fd)
	 (io (fd-for kernel pid fd #t)
	     (list 'ready? pid index)))
       (all-fds-in-xargs xargs))
      (cond
       ((eq? (car xrvalue) 0)
	(for-each
	 (lambda (fd)
	   (io (fd-for kernel pid fd #t)
	       (list 'timeout (ref xargs 2) pid index)))
	 (all-fds-in-xargs xargs)))
       (else
	(for-each
	 (lambda (fd)
	   (io (fd-for kernel pid (car fd) #t)
	       (list 'ready! pid (cdr fd) index)))

	 (all-fds-in-xrvalue xrvalue))))))
  :resumed
  (lambda (kernel pid call xargs xrvalue xerrno unfinished? time index)
    (when (>= (car xrvalue) 0)
      (for-each
       (lambda (fd)
	 (io (fd-for kernel pid fd #t)
	     (list 'ready? pid index)))
       (all-fds-in-xargs xargs))
      (cond
       ((eq? (car xrvalue) 0)
	(for-each
	 (lambda (fd)
	   (io (fd-for kernel pid fd #t)
	       (list 'timeout (ref xargs 2) pid index)))
	 (all-fds-in-xargs xargs)))
       (else
	(for-each
	 (lambda (fd)
	   (io (fd-for kernel pid (car fd) #t)
	       (list 'ready! pid (cdr fd) index)))

	 (all-fds-in-xrvalue xrvalue)))))))

#; ( 
(accept . 7666)
; (fcntl64 . 39226)
 (ftruncate . 1)
 (getdents . 4)
 (getdents64 . 4234)
 (ioctl . 550)
 (poll . 115774)
 (setsockopt . 22352))
  
(provide "trapeagle/syscalls/io")
