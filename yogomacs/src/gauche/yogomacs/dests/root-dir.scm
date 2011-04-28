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
  (use yogomacs.dests.annotations-dir)
  (use yogomacs.dests.dists-dir)
  (use yogomacs.dests.packages-dir)
  (use yogomacs.dests.root-commands-dir)
  (use yogomacs.dests.sources-dir)
  (use yogomacs.dests.absentees-dir)
  ;;
  (use yogomacs.dests.text)
  (use yogomacs.dests.ysh-dir)
  (use yogomacs.dests.debug)
  ;;
  (use yogomacs.reply)
  ;;
  (use yogomacs.config)
  )
(select-module yogomacs.dests.root-dir)

;; TODO: unavailable
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
    :text #`"This directory tree holds version ,(version) of yogomacs, the extensible(TODO),
customizable(TODO), self-documenting(TODO) real-time display source viewer.\n"))

(define (NEWS-entry parent-path)
  (make <text-dentry>
    :parent (compose-path parent-path)
    :dname "NEWS"
    :text "NOTHING HERE"))

(define (annotations-entry parent-path)
  (make <redirect-dentry>
    :parent (compose-path parent-path)
    :dname "annotations"))
(define (commands-entry parent-path)
  (make <redirect-dentry>
    :parent (compose-path parent-path)
    :dname "commands"))
(define (login-entry parent-path)
  (make <redirect-dentry>
    :parent (compose-path parent-path)
    :url "commands/login"
    :dname "login"
    :show-arrowy-to #t))
(define (absentees-entry parent-lpath)
  (make <redirect-dentry>
    :parent (compose-path parent-lpath)
    :dname "absentees"))

(define (dest path params config)
  (let1 shtml (dired
	       (compose-path path)
	       (append 
		(glob-dentries (config 'real-sources-dir)
			       root-globs)
		`( 
		  ,(README-entry path)
		  ,(NEWS-entry path)
		  ,(commands-entry path)
		  ,(absentees-entry path)
		  ,@(if (in-shell? params)
			`(,(annotations-entry path))
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

(define (TEXT-dest entry path params config)
  (text-dest (entry (parent-of path))
	     path params config
	     ))

(define (login-dest path params config)
  (list
   (cgi-header :status "302 Moved Temporarily"
	       :location (url-of (login-entry (parent-of path))))))

(define (routing-table path params)
   `((#/^\/$/ ,dest)
     (#/^\/annotations(?:\/.+)?$/ ,annotations-dir-dest)
     (#/^\/commands(?:\/.+)?$/   ,root-commands-dir-dest)
     (#/^\/dists(?:\/.+)?$/   ,dists-dir-dest)
     (#/^\/packages(?:\/.+)?$/   ,packages-dir-dest)
     (#/^\/sources(?:\/.+)?$/ ,sources-dir-dest)
     (#/^\/absentees(?:\/.+)?$/ ,absentees-dir-dest)
     (#/^\/ysh(?:\/.+)?$/   ,ysh-dir-dest)

     ;;
     ,@(if (in-shell? params)
	   (list
	    )
	   (list
	    `(#/^\/login$/  ,login-dest)
	    ))
     (#/^\/README$/  ,(pa$ TEXT-dest README-entry))
     (#/^\/NEWS$/  ,(pa$ TEXT-dest NEWS-entry))
     ;; 403
     ;(#/^.*$/ ,print-path)
     ))


(define (root-dir-dest lpath params config)
  (route (routing-table lpath params) (compose-path lpath) params config))



(provide "yogomacs/dests/root-dir")