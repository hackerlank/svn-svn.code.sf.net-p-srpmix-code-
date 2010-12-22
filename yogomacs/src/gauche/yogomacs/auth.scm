(define-module yogomacs.auth
  (export authorized?
	  unauthorized)
  (use rfc.base64)
  (use www.cgi)
  (use yogomacs.user)
  (use yogomacs.role)
  )

(select-module yogomacs.auth)

(define (authorized? config)
  (and-let* ((auth-string (cgi-get-metavariable "HTTP_CGI_AUTHORIZATION"))
	     (m (#/ *Basic (.*)$/ auth-string))
	     (base64-encoded (m 1))
	     (base64-decoded (string-split 
			      (base64-decode-string base64-encoded)
			      ":"))
	     ( (list? base64-decoded) )
	     ( (eq? (length base64-decoded) 2) )
	     (user+role (string-split (car base64-decoded) ","))
	     ( (list? user+role) )
	     (user-name (car user+role))
	     (role-name (if (null? (cdr user+role)) (default-role-name config) (cadr user+role)))
	     (passwd (cadr base64-decoded))
	     (u (user? user-name passwd))
 	     )
    (list u role-name)))


(define (unauthorized config)
  (let1 realm (or (config 'realm) "Sources")
    (list
      (cgi-header :status "401 Unauthorized"
		  :WWW-Authenticate #`"Basic realm=\",|realm|\""
		  ))))

(provide "yogomacs/auth")