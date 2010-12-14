(define-module yogomacs.shells
  (extend yogomacs.shell)

  (use yogomacs.shells.ysh)
  (use yogomacs.shells.bscm)
  (use yogomacs.shells.nologin)
  )

(select-module yogomacs.shells)

(provide "yogomacs/shells")
