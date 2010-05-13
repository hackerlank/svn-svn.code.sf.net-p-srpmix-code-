(define-module trapeagle.controls.show
  (use trapeagle.control)
  (use trapeagle.hook)
  (use trapeagle.backing-store)
  (use gauche.hook)  
  (use srfi-1)
  )
(select-module trapeagle.controls.show)

(let1 backing-store (make <backing-store>
		      :template "trapeagle"
		      :get-key (lambda (obj) (cadr (memq :index obj))))
  (define (writeln r)
    (write r)
    (newline)
    (flush)
    )
  (define (show n)
    (let1 r (read-for backing-store n)
      (writeln r)
      r))
  (add-hook! input-hook (lambda (r)
			  (when (eq? (car r) 'strace)
			    (write r backing-store))))
  (add-hook! quit-hook (lambda (n)
			 (close-port backing-store)))
  (defcontrol show (kernel . args)
    "Show strace data:
 (show N...)
 (show (B E)...)"
    (for-each 
     (lambda (spec)
       (cond
	((number? spec)
	 (show spec))
	((pair? spec)
	 (let loop ((current (car spec))
		    (end (cadr spec)))
	   (when (<= current end)
	     (show current)
	     (loop (+ current 1) end)))
	 )))
     args)))
  

(provide "trapeagle/controls/show")