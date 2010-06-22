(define-module font-lock.harnesses.screen
  (export <screen-harness>
	  launch)
  (use font-lock.harness)
  (use srfi-1)
  (use gauche.process))

(select-module font-lock.harnesses.screen)


(define-class <screen-harness> (<harness>)
  ((name :init-value "screen")))
(define-harness (make <screen-harness>))

(define-method launch ((screen-harness <screen-harness>)
		       cmdline
		       params
		       verbose
		       )
  (run-process (cons* "screen"
		      "-d"
		      "-m"
		      (car cmdline)
		      "-nw"
		      (cdr cmdline))
	       :wait #f
	       :error (if verbose #f "/dev/null"))
  0)

(provide "font-lock/harnesses/screen")
