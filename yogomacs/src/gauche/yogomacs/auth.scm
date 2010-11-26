(define-module yogomacs.auth
  (export authorized?
	  unauthorized)
  (use rfc.base64)
  (use www.cgi)
  )

(select-module yogomacs.auth)

(define (authorized?)
  (let1 auth-string (cgi-get-metavariable "HTTP_CGI_AUTHORIZATION")
    (if auth-string
	(rxmatch-if (#/ *Basic (.*)$/ auth-string)
	    (#f base64-encoded)
	  (let1 base64-decoded (string-split 
				(base64-decode-string base64-encoded)
				":")
	    (if (and base64-decoded
		     (list? base64-decoded)
		     (eq? (length base64-decoded) 2))
		#t
		#f))
	  #f)
	#f)))

(define (unauthorized config)
  (let1 realm (or (config 'realm) "Sources")
    (list
     (cgi-header :status "401 Unauthorized"
		 :WWW-Authenticate #`"Basic realm=\",|realm|\""
		 ))))

(provide "yogomacs/auth")
	  