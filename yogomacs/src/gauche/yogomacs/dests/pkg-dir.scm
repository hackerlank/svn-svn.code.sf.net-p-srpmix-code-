(define-module yogomacs.dests.pkg-dir
  (export pkg-dir-dest)
  ;;
  (use yogomacs.route)
  (use yogomacs.dentry)

  (use yogomacs.path)
  (use yogomacs.dests.dir)

  (use yogomacs.dests.srpmix-dir)
  (use yogomacs.dests.lcopy-dir)
  (use srfi-1)
  (use file.util)
  (use yogomacs.lcopy)
  )
(select-module yogomacs.dests.pkg-dir)

(define (lcopy-spec path config)
  (let* ((last (last path))
	 (head (path->head path))
	 (lcopy-path (lambda (root e) 
		       (build-path root 
				   head
				   last
				   (dname-of e)))))
    `((,#/\^lcopy-[^\/]+/ 
		  #t
		  ,(lambda (fs-dentry) 
		     (lcopy-path "/" fs-dentry))
		  ,(lambda (fs-dentry)
		     (lcopy-dir->checkout-cmdline 
		      (lcopy-path (config 'real-sources-dir)
				  fs-dentry)))
		  ;; XXX
		  ))))

(define (dest path params config)
  (dir-dest path params config
	       (lcopy-spec path config)))

(define routing-table
  `((#/^\/sources\/[a-zA-Z0-9]\/[^\/]+$/ ,dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/\^lcopy-([^\/]+)(?:\/.+)?$/ ,lcopy-dir-dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)(?:\/.+)?$/ ,srpmix-dir-dest)
    ))

(define (pkg-dir-dest path params config)
  (route routing-table (compose-path path) params config))


(provide "yogomacs/dests/pkg-dir")