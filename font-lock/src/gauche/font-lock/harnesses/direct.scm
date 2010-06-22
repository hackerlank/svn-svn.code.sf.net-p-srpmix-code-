(define-module font-lock.harnesses.direct
  (export <direct-harness>
	  launch)
  (use font-lock.harness)
  (use gauche.process)
  )

(select-module font-lock.harnesses.direct)


(define-class <direct-harness> (<harness>)
  ((name :init-value "direct")))
(define-harness (make <direct-harness>))

(define-method launch ((direct-harness <direct-harness>)
		       cmdline
		       params
		       verbose
		       )
  (let1 proc (run-process cmdline :wait #f :error (if verbose #f "/dev/null"))
    (process-wait proc)
    (process-exit-status proc)))

(provide "font-lock/harnesses/direct")
