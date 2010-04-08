(define-module trapeagle.syscalls.fd
  (use trapeagle.type)
  (use trapeagle.syscall)
  )

(select-module trapeagle.syscalls.fd)

(defsyscall open
  :trace 
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (write xargs)
    (newline)
    #f)
  :unfinished
  (lambda (kernel pid resumed? time index)
    #f)
  )

(defsyscall socket
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (write xargs)
    (newline)
    #f)
  )

(provide "trapeagle/syscalls/fd")