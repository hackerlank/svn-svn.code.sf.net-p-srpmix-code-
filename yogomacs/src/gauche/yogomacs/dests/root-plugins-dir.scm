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
    :parent "/plugins" :dname ysh-name :url ysh-url))
(define (ysh-dest path params config)
  (list
   (cgi-header :status "302 Moved Temporarily"
	       :location ysh-url)))

(define bscm-url  "/bscm")
(define bscm-name "bscm")
(define (bscm-entry parent-path)
  (make <redirect-dentry>
    :parent "/plugins" :dname bscm-name :url bscm-url))
(define (bscm-dest path params config)
  (list
   (cgi-header :status "302 Moved Temporarily"
	       :location bscm-url)))


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
		   ((equal? yogomacs ysh-name) (list (bscm-entry path)))
		   ((equal? yogomacs bscm-name) (list (ysh-entry path)))
		   (else (list  
			  (bscm-entry path)
			  (ysh-entry path)))))
		 css-route)))
    (prepare-dired-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose integrate-dired-face) shtml)
      :last-modification-time #f)))

(define routing-table
  `((#/^\/plugins$/ ,dest)
    (#/^\/plugins/ysh$/ ,ysh-dest)
    (#/^\/plugins/bscm$/ ,bscm-dest)
    #;(#/^\/plugins/login$/ ,dest)
    ))

(define (root-plugins-dir-dest path params config)
  (route routing-table (compose-path path) params config))

(provide "yogomacs/dests/root-plugins-dir")