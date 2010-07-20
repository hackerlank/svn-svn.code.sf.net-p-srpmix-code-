(define-module yogomacs.dests.dir
  (export prepare-dired-faces
	  integrate-dired-face
	  dir-dest)
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
	:data ((compose integrate-dired-face) (dired 
					       (compose-path path)
					       (glob-dentries real-src-dir 
							      (make-dir-globs (build-path "/" head)
									      last
									      extra))
					       css-route))
	:last-modification-time #f
	)))
   ((path params config)
    (dir-dest path params config (list)))))

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
