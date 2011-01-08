(define-module yogomacs.dests.dir
  (export prepare-dired-faces
	  integrate-dired-face
	  dir-dest
	  ;;
	  dir-make-url
	  dir-make-arrowy-to-dname
	  dir-make-arrowy-to-url
	  )
  (use srfi-1)
  (use www.cgi)  
  (use file.util)
  ;;
  (use yogomacs.path)
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)
  (use yogomacs.dentries.redirect)
  (use yogomacs.renderers.dired)
  (use util.combinations)
  ;;
  (use yogomacs.reply)
  (use yogomacs.storages.css)
  ;;
  (use util.match)
  (use yogomacs.dests.css)
  (use yogomacs.rearranges.face-integrates)
  (use yogomacs.rearranges.checkout)
  ;;
  (use yogomacs.error)
  (use yogomacs.domain)
  (use yogomacs.access)
  )

(select-module yogomacs.dests.dir)

(define integrate-dired-face
   (cute face-integrates <> "dired-font-lock" dired-faces))

(define (prepare-dired-faces config)
  (for-each
   (lambda (face-style)
     (prepare-css-cache config
			(car face-style)
			(cadr face-style)
			'(dired)))
   (cartesian-product `(,dired-faces ,dired-styles))))

(define (preprocess-dentries dentries config)
  (and dentries
       (map (lambda (dentry)
	      (cond
	       ((and (equal? (dname-of dentry) ".")
		     (archivable? (parent-path-of dentry) config))
		(make <redirect-dentry>
		  :parent (ref dentry 'parent)
		  :dname "."
		  :url #`"/commands/checkout,(path-of dentry)"
		  :show-arrowy-to "commands/checkout")
		)
	       (else
		dentry)))
	    dentries)))

(define dir-dest 
  (match-lambda*
   ((path params config extra)
    (let* ((last (last path))
	   (head (path->head path))
	   (real-src-dir (build-path (config 'real-sources-dir)
				     head last)))
      ;;
      (unless (to-domain? real-src-dir config)
	(forbidden "Out of domain" real-src-dir))
      ;;
      (let1 dentries (preprocess-dentries
		      (glob-dentries real-src-dir 
				     (make-dir-globs (build-path "/" 
								 head)
						     last
						     extra))
		      config)
	
	(if dentries
	    (begin (prepare-dired-faces config)
		   (make <shtml-data>
		     :params params
		     :config config
		     :data ((compose integrate-dired-face)
			    (dired 
			     (compose-path path)
			     dentries
			     css-route))
		     :last-modification-time #f))
	    (not-found #`"Cannot find ,(compose-path path)" 
		       #`",|real-src-dir| for ,(compose-path path)")))))
   ((path params config)
    (dir-dest path params config (list)))))

(define (dir-make-url path e)
  (let1 entry-path (path-of e)
    (if (file-is-readable? entry-path)
	(compose-path* path (dname-of e))
	#f)))

(define (dir-make-arrowy-to-dname e)
  (let1 entry-path (path-of e)
    (guard (e (else #f))
      (sys-basename (sys-readlink entry-path)))))

(define (dir-make-arrowy-to-url get-pkg e)
  (let* ((pkg (get-pkg e))
	 (entry-path (path-of e))
	 (ver (guard (e
		      (else #f))
		(sys-basename (sys-readlink entry-path)))))
    (if ver
	(build-path "/sources"
		    (substring pkg 0 1)
		    pkg
		    ver)
	#f)))

(define make-dir-globs
  (match-lambda*
   ((base last extra)
    `(("."  #t ,(build-path base last))
      (".." #t ,base)
      ,@extra
      (#/.*/ #t ,(lambda (fs-dentry) 
		   (build-path base 
			       last
			       (dname-of fs-dentry))) #f)))
   ((base last)
    (make-dir-globs base last (list)))))

(provide "yogomacs/dests/dir")
