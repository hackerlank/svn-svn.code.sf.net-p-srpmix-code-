(define-module yogomacs.dests.login
  (export login-dest
	  guest-dest
	  )
  (use yogomacs.reply)
  (use yogomacs.auth)
  (use yogomacs.shells)
  )
(select-module yogomacs.dests.login)

(define (login-dest0 lpath params config checker)
  (if-let1 user+role (checker)
	   (let1 params ((params "user" (car user+role)) "role" (cadr user+role))
	     (make <redirect-data> 
	       :location (url-of (shell-ref (ref (params "user") 'shell)))))
	   (unauthorized config)))

(define (login-dest lpath params config)
  (login-dest0 lpath params config (pa$ authorized? config)))

(define (guest-dest lpath params config)
  (login-dest0 lpath params config 
	       (pa$ maybe-login params config)))

(provide "yogomacs/dests/login")