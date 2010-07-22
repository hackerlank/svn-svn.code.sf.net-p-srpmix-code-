(define-module yogomacs.dests.dir
  (export prepare-dired-faces
	  integrate-dired-face
	  dir-dest
	  ;;
	  dir-make-url
	  dir-make-symlink-to-dname
	  dir-make-symlink-to-url
	  )
  (use srfi-1)
  (use www.cgi)  
  (use file.util)
  ;;
  (use yogomacs.path)
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)
  (use yogomacs.renderers.dired)
  (use util.combinations)
  ;;
  (use yogomacs.reply)
  (use yogomacs.caches.css)
  ;;
  (use util.match)
  (use yogomacs.dests.css)
  (use yogomacs.rearranges.face-integrates))

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

(define dir-dest 
  (match-lambda*
   ((path params config extra)
    (let* ((last (last path))
	   (head (path->head path))
	   (real-src-dir (build-path (config 'real-sources-dir)
				     head last)))
      (prepare-dired-faces config)
      (make <shtml-data>
	:params params
	:config config
	:data ((compose integrate-dired-face) (dired 
					       (compose-path path)
					       (glob-dentries real-src-dir 
							      (make-dir-globs (build-path "/" 
											  head)
									      last
									      extra))
					       css-route))
	:last-modification-time #f
	)))
   ((path params config)
    (dir-dest path params config (list)))))

(define (dir-make-url path e)
  (let1 entry-path (path-of e)
    (if (file-is-readable? entry-path)
	(compose-path* path (dname-of e))
	#f)))

(define (dir-make-symlink-to-dname e)
  (let1 entry-path (path-of e)
    (guard (e (else #f))
      (sys-basename (sys-readlink entry-path)))))

(define (dir-make-symlink-to-url get-pkg e)
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
