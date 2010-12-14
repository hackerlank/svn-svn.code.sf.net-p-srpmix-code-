(define-module yogomacs.shells.nologin
  (use yogomacs.shell)
  )
(select-module yogomacs.shells.nologin)

(define-shell nologin (make <shell> 
		     :name "nologin"
		     :prompt " <nologin"
		     :url "/"
		     :interpreter 'nologin-interpret
		     :initializer 'nologin-initializer))

(provide "yogomacs/shells/nologin")