(define-module trapeagle.controls.help
  (use trapeagle.control)
  )

(select-module trapeagle.controls.help)

(define (help cnt)
  (let1 doc (document-for-control cnt)
    (if doc
	(begin 
	  (print doc)
	  (newline)
	  (flush))
	(format (current-error-port) "No such control: ~s\n" cnt))))
	       
(defcontrol help (kernel . args) 
  "Help for controls:
 (help)
 (help CONTROL)"
  (if (null? args)
      (for-each help (all-controls))
      (help (car args))))

(provide "trapeagle/controls/help")