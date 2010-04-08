(define-module trapeagle.syscalls.task
  (use trapeagle.type)
  (use trapeagle.syscall)
  )

(select-module trapeagle.syscalls.task)

(defsyscall clone
  :trace 
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (write xargs)
    (newline)
    #f)
  :unfinished
  (lambda (kernel pid resumed? time index)
    #f)
  )

(defsyscall fork
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (write xargs)
    (newline)
    #f)
  )

(defsyscall execve
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (write xargs)
    (newline)
    #f)
  )

(defsyscall waitpid
  :trace
  (lambda (kernel pid xargs xrvalue xerrno time index)
    (write xargs)
    (newline)
    #f)
  )

(provide "trapeagle/syscalls/task")