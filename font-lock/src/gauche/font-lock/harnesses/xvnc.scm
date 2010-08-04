(define-module font-lock.harnesses.xvnc
  (export <xvnc-harness>
	  launch)
  (use font-lock.harness)
  (use font-lock.harnesses.daemonize)
  (use gauche.process)
  (use file.util)
  (use srfi-1))

(select-module font-lock.harnesses.xvnc)


(define-class <xvnc-harness> (<harness>)
  ((name :init-value "xvnc")))
(define-harness (make <xvnc-harness>))


(define-method parameters-of ((harness <xvnc-harness>))
  (list ":display N"))

(define (prepare-startup-file startup-file)
  ;; TODO: error?
  (call-with-output-file startup-file
    (pa$ display "metacity\n"))
  (sys-chmod startup-file #o744))

(define-method launch ((xvnc-harness <xvnc-harness>)
		       cmdline
		       params
		       verbose)
  (let/cc return
    (let-keywords* params ((display :display 99))
      (let* ((home-dir (home-directory))
	     (passwd-file (build-path home-dir
				      ".vnc"
				      "passwd"))
	     (startup-file (build-path home-dir
				       ".vnc"
				       "xstartup")))
	(unless (file-is-readable? passwd-file)
	  (format (current-error-port)
		  "vnc passwd file is not prepared yet: ~a\n"
		  passwd-file)
	  (return 1))
	(unless (file-is-readable? startup-file)
	  (prepare-startup-file startup-file)
	  )
	(let ((proc (run-process `("vncserver"
				   ,(format ":~d" display))
				 :wait #t
				 :error (if verbose #f "/dev/null")))
	      (daemonize-harness (choose-harness "daemonize"))
	      )
	  ;; Ignore: Only vncserver runs.
	  #;(unless (eq? (process-exit-status proc) 0)
	    (format (current-error-port)
		    "failed to launch vncserver: ~d\n"
		    display)
	    (return 1))
	  (launch daemonize-harness
		  (cons* (car cmdline)
			 "--display"
			 (format ":~d" display)
			 (cdr cmdline))
		  (list)
		  verbose))))))

(provide "font-lock/harnesses/xvnc")
