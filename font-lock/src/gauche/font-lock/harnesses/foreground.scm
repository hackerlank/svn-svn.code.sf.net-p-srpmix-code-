(define-module font-lock.harnesses.foreground
  (export <foreground-harness>
	  launch)
  (use font-lock.harness)
  (use gauche.process)
  )

(select-module font-lock.harnesses.foreground)


(define-class <foreground-harness> (<harness>)
  ((name :init-value "foreground")))
(define-harness (make <foreground-harness>))

(define-method launch ((foreground-harness <foreground-harness>)
		       cmdline
		       params
		       verbose
		       )
  (let1 proc (run-process cmdline :wait #f :error (if verbose #f "/dev/null"))
    (process-wait proc)
    (process-exit-status proc)))

(provide "font-lock/harnesses/foreground")
