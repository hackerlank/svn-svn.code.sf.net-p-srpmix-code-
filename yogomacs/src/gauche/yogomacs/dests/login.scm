(define-module yogomacs.dests.login
  (export login-dest)
  (use yogomacs.auth)
  (use yogomacs.shells)
  )
(select-module yogomacs.dests.login)

(define (login-dest lpath params config)
  (if-let1 user+role (authorized? config)
	   (let1 params ((params "user" (car user+role)) "role" (cadr user+role))
	     (dest-for (shell-ref (ref (params "user") 'shell)) lpath params config)
	     )
	   (unauthorized config)))


(provide "yogomacs/dests/login")