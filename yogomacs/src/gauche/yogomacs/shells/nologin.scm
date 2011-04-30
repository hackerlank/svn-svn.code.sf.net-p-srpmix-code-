(define-module yogomacs.shells.nologin
  (use yogomacs.shell)
  )
(select-module yogomacs.shells.nologin)

(define-shell nologin (make <shell> 
		     :name "nologin"
		     :prompt " <nologin"
		     :url "/"
		     ))

(provide "yogomacs/shells/nologin")