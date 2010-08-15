(define-module yogomacs.dests.root-dir
  (export root-dir-dest)
  (use www.cgi) 
  (use file.util)
  (use srfi-19)
  ;;
  (use yogomacs.route)
  ;;
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)
  (use yogomacs.dentries.text)
  (use yogomacs.dentries.redirect)
  (use yogomacs.renderers.dired)
  (use yogomacs.path)
  (use yogomacs.shell)
  ;;
  (use yogomacs.dests.css)
  (use yogomacs.dests.dir)
  ;;
  (use yogomacs.dests.text)
  (use yogomacs.dests.sources-dir)
  (use yogomacs.dests.dists-dir)
  (use yogomacs.dests.packages-dir)
  (use yogomacs.dests.root-plugins-dir)
  (use yogomacs.dests.ysh-dir)
  (use yogomacs.dests.bscm-dir)
  (use yogomacs.dests.debug)
  ;;
  (use yogomacs.reply)
  )
(select-module yogomacs.dests.root-dir)

(define root-globs
  `(("."  #t "/")
    (".." #t "/")
    (#/^(?:packages|sources|dists)$/ #t ,(lambda (fs-dentry) 
					   (build-path "/"
						       (dname-of fs-dentry))))))

(define (README-entry parent-path)
  (make <text-dentry>
    :parent (compose-path parent-path)
    :dname "README"
    :text "Use the Source, Luke."))
(define (plugins-entry parent-path)
  (make <redirect-dentry>
    :parent (compose-path parent-path)
    :dname "plugins"))
(define (login-entry parent-path)
  (make <redirect-dentry>
    :parent (compose-path parent-path)
    :url "plugins/login"
    :dname "login"
    :show-arrowy-to #t))

(define (dest path params config)
  (let1 shtml (dired
	       (compose-path path)
	       (append 
		(glob-dentries (config 'real-sources-dir)
			       root-globs)
		`( 
		  ,(README-entry path)
		  ,(plugins-entry path)
		  ,@(if (in-shell? params)
			'()
			`(,(login-entry path))
			)
		 ))
	       css-route)
    (prepare-dired-faces config)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose integrate-dired-face) shtml)
      :last-modification-time #f)))

(define (README-dest path params config)
  (text-dest (README-entry (parent-of path))
	     path params config
	     ))

(define (login-dest path params config)
  (list
   (cgi-header :status "302 Moved Temporarily"
	       :location (url-of (login-entry (parent-of path))))))

(define (routing-table path params)
   `((#/^\/$/ ,dest)
     (#/^\/sources(?:\/.+)?$/ ,sources-dir-dest)
     (#/^\/dists(?:\/.+)?$/   ,dists-dir-dest)
     (#/^\/packages(?:\/.+)?$/   ,packages-dir-dest)
     (#/^\/plugins(?:\/.+)?$/   ,root-plugins-dir-dest)
     (#/^\/ysh(?:\/.+)?$/   ,ysh-dir-dest)
     (#/^\/bscm(?:\/.+)?$/   ,bscm-dir-dest)
     ;;
     ,@(if (in-shell? params)
	   (list)
	   (list
	    `(#/^\/login$/  ,login-dest)
	    ))
     (#/^\/README$/  ,README-dest)
     (#/^.*$/ ,print-path)
     ))


(define (root-dir-dest path params config)
   (route (routing-table path params) (compose-path path) params config))



(provide "yogomacs/dests/root-dir")