(define-module trapeagle.controls.trend
  (use trapeagle.control)
  (use trapeagle.syscalls.trend)
  )

(select-module trapeagle.controls.trend)

(defcontrol trend (kernel) 
  "Show system call trends:
 (trend)"
  (format #t "syscalls: ~s\n" 
	  (trend)))

(provide "trapeagle/controls/trend")