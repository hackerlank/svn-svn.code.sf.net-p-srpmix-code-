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
	      xrvalue xerrno index index)))
       :unfinished
       (lambda* (kernel pid call xargs xrvalue xerrno resumed? time index)
	 (io 
	  (fd-for kernel pid (car xargs) #t)
	  (list ,key
		;call
		xrvalue xerrno index #f)))
         :resumed
	 (lambda* (kernel pid call xargs xrvalue xerrno unfinished? time index)
	   (io 
	    (fd-for kernel pid (car xargs) #t)
	    (list ,key 
		  ;call
		  xrvalue xerrno #f index)))))

(defio read     'r)
(defio recv     'r)
(defio recvfrom 'r)

(defio write  'w)
(defio send   'w)
(defio sendto 'w)

(defio close 'close)
(defio connect 'connect)

#; ( 
(accept . 7666)
 (bind . 6410)
 (close . 22711)
 (connect . 7726)
 (fcntl64 . 39226)
 (ftruncate . 1)
 (getdents . 4)
 (getdents64 . 4234)
 (ioctl . 550)
 (listen . 3)
 (poll . 115774)
 (setsockopt . 22352)
 (shutdown . 1))
  
(provide "trapeagle/syscalls/io")