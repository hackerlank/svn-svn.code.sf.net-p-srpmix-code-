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
(defsyscall read
  :trace
  (lambda* (kernel pid xargs xrvalue xerrno time index)
    (io 
     (fd-for kernel pid (car xrvalue))
     (list 'read xrvalue xerrno index index)))
  :unfinished
  (lambda* (kernel pid xargs xrvalue xerrno resumed? time index)
    (io 
     (fd-for kernel pid (car xrvalue))
     (list 'read xrvalue xerrno index #f)))
  :resumed
  (lambda* (kernel pid xargs xrvalue xerrno unfinished? time index)
    (io 
     (fd-for kernel pid (car xrvalue))
     (list 'read xrvalue xerrno #f index))))

(defsyscall write
  :trace
  (lambda* (kernel pid xargs xrvalue xerrno time index)
    (io 
     (fd-for kernel pid (car xrvalue))
     (list 'write xrvalue xerrno index index)))
  :unfinished
  (lambda* (kernel pid xargs xrvalue xerrno resumed? time index)
    (io 
     (fd-for kernel pid (car xrvalue))
     (list 'write xrvalue xerrno index #f)))
  :resumed
  (lambda* (kernel pid xargs xrvalue xerrno unfinished? time index)
    (io 
     (fd-for kernel pid (car xrvalue))
     (list 'write xrvalue xerrno #f index))))

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
 (read . 30926)
 (recv . 604243) 
(recvfrom . 538)
 (send . 331183)
 (setsockopt . 22352)
 (shutdown . 1)
 (write . 3899520))
  
(provide "trapeagle/syscalls/io")