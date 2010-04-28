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

(define-method set-unfinished-syscall! (kernel pid call-info)
  (set! (ref (task-for kernel pid) 
	     'unfinished-syscall) call-info))

(define-method set-unfinished-syscall! (kernel pid resumed? time index)
  (let1 call-info (vector syscall
			  #f
			  #f
			  #f
			  (vector index time)
			  (vector resumed? #f)
			  #f)
    (set-unfinished-syscall! kernel pid call-info)))

(define-method update-info! ((resource  <resource>)
			     (slot      <symbol>)
			     (call-type <symbol>)
			     (syscall   <symbol>)
			     (all-args  <list>)
			     . options)
  ;; #(syscall xargs xrvalue xerrno #(start-index start-time) #(end-index end-time) option...)
  (case call-type
    ('trace
     ;; (kernel pid xargs xrvalue xerrno time index original) =>
     (let* ((new (vector syscall
			 (ref all-args 2) 
			 (ref all-args 3)
			 (ref all-args 4)
			 (vector (ref all-args 6) (ref all-args 5))
			 (vector (ref all-args 6) (ref all-args 5))
			 #f))
	    (original (ref resource slot)))
       (set! (ref resource slot) new)
       (when (get-keyword :record-history options #f)
	 (set! (ref new 6) original)
	 )))
    ('unfinished
     ;; (kernel pid resumed? time index) =>
     (let1 call-info (vector syscall
			     #f
			     #f
			     #f
			     (vector (ref all-args 4) (ref all-args 3))
			     (vector (ref all-args 2) #f)
			     #f)
       (when resource
	 (set! (ref resource 'unfinished-syscall) call-info))
       (set-unfinished-syscall! (ref all-args 0) (ref all-args 1) call-info)
       ))
    ('resumed
     ;; (kernel pid xargs xrvalue xerrno unfinished? time index history)
     (let* ((kernel (ref all-args 0))
	    (pid (ref all-args 1))
	    (unfinished (ref (task-for kernel pid) 'unfinished-syscall))
	    (original (ref resource slot)))
       (set! (ref resource 'unfinished-syscall) #f)
       (let1 resumed (if unfinished
			 (begin
			   (set! (ref unfinished 1) (ref all-args 2))
			   (set! (ref unfinished 2) (ref all-args 3))
			   (set! (ref unfinished 3) (ref all-args 4))
			   (set! (ref (ref unfinished 4) 0) (ref all-args 5))
			   (set! (ref (ref unfinished 5) 1) (ref all-args 6))
			   (set! (ref (ref unfinished 5) 0) (ref all-args 7))
			   (clear-unfinished-syscall! kernel pid)
			   unfinished)
			 (vector syscall
				 (ref all-args 2) 
				 (ref all-args 3)
				 (ref all-args 4)
				 (vector (ref all-args 5) #f)
				 (vector (ref all-args 7) (ref all-args 6))
				 #f))
	 (set! (ref resource slot) resumed)
	 (when (get-keyword :record-history options #f)
	   (set! (ref resumed 6) original)))))
    ))

(provide "trapeagle/call-info")