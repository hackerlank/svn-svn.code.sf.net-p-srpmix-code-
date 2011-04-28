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
  (use yogomacs.shells)
  (use yogomacs.commands.checkout)
  (use yogomacs.dests.login)
  ;;
  )
(select-module yogomacs.dests.root-commands-dir)

(define (dest lpath params config)
  (let* ((yogomacs (in-shell? params))
	 (shtml (dired
		 (compose-path lpath)
		 (cons* 
		  (current-directory-dentry lpath)
		  (parent-directory-dentry lpath)
		  (cond
		   (filter 
		    (lambda (shell)
		      (not (equal? yogomacs (ref shell 'name))))
		    (map 
		     (lambda (shell)
		       (entry-for shell lpath))
		     (all-shells)))))
		 css-route)))
    (prepare-dired-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose integrate-dired-face) shtml)
      :last-modification-time #f)))

(define (routing-table path params)
  `((#/^\/commands$/ ,dest)
    (#/^\/commands\/ysh$/ ,(pa$ dest-for (shell-ref 'ysh)))
    (#/^\/commands\/checkout\/.*/ ,checkout-dest)
    ,@(if (in-shell? params)
	  (list)
	  (list
	   `(#/^\/commands\/login$/ ,login-dest)
	   ))))

(define (root-commands-dir-dest path params config)
  (route (routing-table path params) (compose-path path) params config))

(provide "yogomacs/dests/root-commands-dir")