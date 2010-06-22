(define-module font-lock.harnesses.xvnc
  (export <xvnc-harness>)
  (use font-lock.harness)
  )
(select-module font-lock.harnesses.xvnc)

(define-class <xvnc-harness> (<harness>)
  ((name :init-value "xvnc")))
;(define-harness (make <screen-harness>))

(provide "font-lock/harnesses/xvnc")
