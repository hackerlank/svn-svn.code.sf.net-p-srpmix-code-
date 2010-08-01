(define-module yogomacs.shells.bscm
  (use yogomacs.shell)
  )
(select-module yogomacs.shells.bscm)

(define-shell bscm (make <shell> :name "bscm" :prompt " <bscm"))

(provide "yogomacs/shells/bscm")