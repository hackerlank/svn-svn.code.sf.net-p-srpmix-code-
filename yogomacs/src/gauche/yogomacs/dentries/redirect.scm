(define-module yogomacs.dentries.redirect
  (export <redirect-dentry>
	  )
  (use yogomacs.dentry)
  (use yogomacs.dentries.virtual)
  )
(select-module yogomacs.dentries.redirect)

(define-class <redirect-dentry> (<virtual-dentry> <arrowy-dentry>)
  ((url :init-keyword :url :init-value #f)
   (show-arrowy-to :init-keyword :show-arrowy-to :init-value #f)
   ))

(define-method type-marker-of ((d <redirect-dentry>))
  (let1 url (url-of d)
    (if (or (#/^http:\/\/.*/ url)
	    (#/^ftp:\/\/.*/ url))
	#\x
	#\v)))

(define-method url-of ((redirect <redirect-dentry>))
  (or (ref redirect 'url)
      (path-of redirect)))

(define-method arrowy-to-dname-of ((d <redirect-dentry>))
  (let1 show-arrowy-to (ref d 'show-arrowy-to)
    (cond
     ((eq? show-arrowy-to #t) (url-of d))
     ((string? show-arrowy-to) show-arrowy-to)
     (else
      #f))))

(provide "yogomacs/dentries/redirect")
