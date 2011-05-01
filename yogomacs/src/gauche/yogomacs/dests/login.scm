(define-module yogomacs.dests.login
  (export login-dest
	  maybe-login)
  (use yogomacs.reply)
  (use yogomacs.auth)
  (use yogomacs.shells)
  )
(select-module yogomacs.dests.login)

(define (login-dest lpath params config)
  (if-let1 user+role (maybe-login)
	   (let1 params ((params "user" (car user+role)) "role" (cadr user+role))
	     (make <redirect-data> 
	       :location (url-of (shell-ref (ref (params "user") 'shell)))))
	   (unauthorized config)))

(provide "yogomacs/dests/login")