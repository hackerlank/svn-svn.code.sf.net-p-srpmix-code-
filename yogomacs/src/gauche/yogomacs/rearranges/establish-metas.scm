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

(define (establish-metas sxml)
  (let ((user-agent (assoc-ref (sys-environ->alist) 
			       "HTTP_USER_AGENT"
			       "")))
    (install-meta sxml
		  :user-agent user-agent
		  :smart-phone? (smart-phone? user-agent))))

(provide "yogomacs/rearranges/establish-metas")
