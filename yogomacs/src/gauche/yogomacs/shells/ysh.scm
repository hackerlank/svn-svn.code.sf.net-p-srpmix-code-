(define-module yogomacs.shells.ysh
  (use yogomacs.shell)
  )
(select-module yogomacs.shells.ysh)

(define-shell ysh (make <shell> 
		    :name "ysh"
		    :prompt " <ysh"
		    :interpreter 'ysh-interpret))

(provide "yogomacs/shells/ysh")