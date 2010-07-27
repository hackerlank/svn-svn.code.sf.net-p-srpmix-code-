(define-module yogomacs.dests.root-plugins-dir
  (export root-plugins-dir-dest)
  (use yogomacs.dentry)
  (use srfi-1)
  (use www.cgi)
  ;(use yogomacs.dentries.virtual)
  (use yogomacs.dentries.redirect)
  (use yogomacs.dests.css)
  (use yogomacs.renderers.dired)
  (use yogomacs.path)
  (use yogomacs.dests.dir)
  (use yogomacs.reply)
  (use yogomacs.route)
  (use yogomacs.shell)
  )
(select-module yogomacs.dests.root-plugins-dir)

(define ysh-url  "/ysh")
(define ysh-name "ysh")
(define (ysh-entry parent-path)
  (make <redirect-dentry>
    :parent (compose-path parent-path) :dname ysh-name :url ysh-url))


(define (dest path params config)
  (let* ((yogomacs (in-shell? params))
	 (shtml (dired
		 (compose-path path)
		 (cons* 
		  (make <redirect-dentry>
		    :parent (compose-path path)
		    :dname "." 
		    :url (compose-path* path "."))
		  (make <redirect-dentry>
		    :parent (compose-path path)
		    :dname ".." 
		    :url (compose-path* path ".."))
		  (cond
		   ((equal? yogomacs ysh-name) (list))
		   (else (list  (ysh-entry path)))))
		 css-route)))
    (prepare-dired-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose integrate-dired-face) shtml)
      :last-modification-time #f)))

(define (ysh-dest path params config)
  (list
   (cgi-header :status "302 Moved Temporarily"
	       :location ysh-url)))

(define routing-table
  `((#/^\/plugins$/ ,dest)
    (#/^\/plugins/ysh$/ ,ysh-dest)
    #;(#/^\/plugins/login$/ ,dest)
    ))

(define (root-plugins-dir-dest path params config)
  (route routing-table (compose-path path) params config))

(provide "yogomacs/dests/root-plugins-dir")