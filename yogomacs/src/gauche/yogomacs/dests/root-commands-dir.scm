(define-module yogomacs.dests.root-commands-dir
  (export root-commands-dir-dest)
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
  (use yogomacs.commands.checkout)
  )
(select-module yogomacs.dests.root-commands-dir)

(define ysh-url  "/ysh")
(define ysh-name "ysh")
(define (ysh-entry parent-path)
  (make <redirect-dentry>
    :parent "/commands" :dname ysh-name :url ysh-url))
(define (ysh-dest path params config)
  (list
   (cgi-header :status "302 Moved Temporarily"
	       :location ysh-url)))

(define bscm-url  "/bscm")
(define bscm-name "bscm")
(define (bscm-entry parent-path)
  (make <redirect-dentry>
    :parent "/commands" :dname bscm-name :url bscm-url))
(define (bscm-dest path params config)
  (list
   (cgi-header :status "302 Moved Temporarily"
	       :location bscm-url)))

(define (login-entry parent-path)
  (make <redirect-dentry>
    :parent "/commands" 
    :dname "login" 
    :url "ysh"
    :show-arrowy-to "./ysh"))

(define (dest path params config)
  (let* ((yogomacs (in-shell? params))
	 (shtml (dired
		 (compose-path path)
		 (cons* 
		  (current-directory-dentry lpath)
		  (parent-directory-dentry lpath)
		  (cond
		   ((equal? yogomacs ysh-name) (list (bscm-entry path)))
		   ((equal? yogomacs bscm-name) (list (ysh-entry path)))
		   (else `(  
			  ,(bscm-entry path)
			  ,(login-entry path)
			  ,(ysh-entry path)))))
		 css-route)))
    (prepare-dired-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose integrate-dired-face) shtml)
      :last-modification-time #f)))

(define (routing-table path params)
  `((#/^\/commands$/ ,dest)
    (#/^\/commands\/ysh$/ ,ysh-dest)
    (#/^\/commands\/bscm$/ ,bscm-dest)
    (#/^\/commands\/checkout\/.*/ ,checkout-dest)
    ,@(if (in-shell? params)
	  (list)
	  (list
	   `(#/^\/commands\/login$/ ,ysh-dest)
	   ))))

(define (root-commands-dir-dest path params config)
  (route (routing-table path params) (compose-path path) params config))

(provide "yogomacs/dests/root-commands-dir")