(define-module yogomacs.dentries.redirect
  (export <redirect-dentry>
	  )
  (use yogomacs.dentry)
  (use yogomacs.dentries.virtual)
  )
(select-module yogomacs.dentries.redirect)

(define-class <redirect-dentry> (<virtual-dentry> <arrowy-dentry>)
  ((url :init-keyword :url :init-value #f)))

(define-method type-marker-of ((d <redirect-dentry>))
  (let1 url (url-of d)
    (if (or (#/^http:\/\/.*/ url)
	    (#/^ftp:\/\/.*/ url))
	#\x
	#\v)))

(define-method url-of ((redirect <redirect-dentry>))
  (or (ref redirect 'url)
      (path-of redirect)))

(provide "yogomacs/dentries/redirect")
