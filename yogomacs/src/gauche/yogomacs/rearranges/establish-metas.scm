(define-module yogomacs.rearranges.establish-metas
  (export establish-metas)
  (use yogomacs.util.sxml)
  (use util.list)
  )

(select-module yogomacs.rearranges.establish-metas)

(define smart-phone-user-agents '(
				  ;; doesn't have real keyboard.
				  #/HTCX06HT/
				  #/HTC Magic/
				  #/GT-P1000/
				  #/iPhone OS 4/
				  ;; has real keyboard....
				  #/Android Dev Phone 1/
				  #/IS01 Build\/S8040/
				  ))

(define (smart-phone? user-agent)
  (boolean (any (cute <> user-agent) 
		smart-phone-user-agents)))

(define (role-name params)
  (let1 role (params "role")
    (let1 role-name (or role  #f)
      role-name)))

(define (establish-metas sxml params config)
  (let ((user-agent (assoc-ref (sys-environ->alist) 
			       "HTTP_USER_AGENT"
			       ""))
	(user (params "user")))
    (install-meta sxml
		  :user-agent user-agent
		  :smart-phone? (smart-phone? user-agent)
		  :user-name (if user (ref user 'name) #f)
		  :user-real-name (if user (ref user 'real-name) #f)
		  :role-name (role-name params))))

(provide "yogomacs/rearranges/establish-metas")
