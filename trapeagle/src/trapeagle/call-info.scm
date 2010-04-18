(define-module trapeagle.call-info
  (use trapeagle.resource)
  (use trapeagle.linux)
  (export update-info!
	  clear-unfinished-syscall!)
  )

(select-module trapeagle.call-info)

;; 
(define (clear-unfinished-syscall! kernel pid)
  (set! (ref (task-for kernel pid) 
	     'unfinished-syscall) #f))
  
(define-method update-info! ((resource  <resource>)
			     (slot      <symbol>)
			     (call-type <symbol>)
			     (syscall   <symbol>)
			     (all-args  <list>))
  ;; #(syscall xargs xrvalue xerrno #(start-index start-time) #(end-index end-time))
  (case call-type
    ('trace
     ;; (kernel pid xargs xrvalue xerrno time index) =>
     (set! (ref resource slot)
	   (vector syscall
		   (ref all-args 2) 
		   (ref all-args 3)
		   (ref all-args 4)
		   (vector (ref all-args 6) (ref all-args 5))
		   (vector (ref all-args 6) (ref all-args 5)))))
    ('unfinished
     ;; (kernel pid resumed? time index) =>
     (let1 call-info (vector syscall
			     #f
			     #f
			     #f
			     (vector index time)
			     (vector resumed? #f))
       (when resource
	 (set! (ref resource 'unfinished-syscall) call-info)
	 (set! (ref resource slot) call-info))
       (set! (ref (task-for (ref all-args 0) (ref all-args 1)) 
		  'unfinished-syscall) call-info)))
    ('resumed
     ;; (kernel pid xargs xrvalue xerrno unfinished? time index)
     (let1 old-value (ref (task-for (ref all-args 0) (ref all-args 1)) 
			  'unfinished-syscall)
       (set! (ref resource 'unfinished-syscall) #f)
       (if old-value
	   (let1 old-value (ref resource slot)
	     (set! (ref old-value 1) (ref all-args 2))
	     (set! (ref old-value 2) (ref all-args 3))
	     (set! (ref old-value 3) (ref all-args 4))
	     (set! (ref (ref old-value 4) 0) (ref all-args 5))
	     (set! (ref (ref old-value 5) 1) (ref all-args 6))
	     (set! (ref (ref old-value 5) 0) (ref all-args 7))
	     (set! (ref resource slot) old-value)
	     (clear-unfinished-syscall! (ref all-args 0) (ref all-args 1))
	     )
	   (set! (ref resource slot)
		 (vector syscall
			 (ref all-args 2) 
			 (ref all-args 3)
			 (ref all-args 4)
			 (vector (ref all-args 5) #f)
			 (vector (ref all-args 7) (ref all-args 6)))))))))

(provide "trapeagle/call-info")