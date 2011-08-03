(define-module yogomacs.dests.pkg-dir
  (export pkg-dir-dest)
  ;;
  (use yogomacs.route)
  (use yogomacs.dentry)

  (use yogomacs.path)
  (use yogomacs.dests.dir)

  (use yogomacs.dests.srpmix-dir)
  (use yogomacs.dests.lcopy-dir)
  (use yogomacs.dests.alias-dir)
  (use srfi-1)
  (use file.util)
  (use yogomacs.util.lcopy)
  ;;
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)
  )
(select-module yogomacs.dests.pkg-dir)

(define (spec path config)
  (let* ((last (last path))
	 (head (path->head path))
	 (lcopy-path (lambda (root e) 
		       (build-path root 
				   head
				   last
				   (dname-of e))))
	 (get-pkg (lambda (_)
		    (car (reverse path)))))
    `((#/\^alias-[^\/]+/ 
		 #t
		 ,(pa$ dir-make-url path)
		 ,dir-make-arrowy-to-dname
		 ,(pa$ dir-make-arrowy-to-url
			  get-pkg)
		 )
      (#/\^lcopy-[^\/]+/ 
		 #t
		 ,(lambda (fs-dentry) 
		    (lcopy-path "/" fs-dentry))
		 ,(lambda (fs-dentry)
		    (lcopy-dir->checkout-cmdline 
		     (lcopy-path (config 'real-sources-dir)
				 fs-dentry))))
      (#/\^plugins$/ #f #f)
      )))

(define (dest path params config)
  (dir-dest path params config
	       (spec path config)))

(define routing-table
  `((#/^\/sources\/[a-zA-Z0-9]\/[^\/]+$/ ,dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/\^lcopy-([^\/]+)(?:\/.+)?$/ ,lcopy-dir-dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/\^alias-([^\/]+)(?:\/.+)?$/ ,alias-dir-dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)(?:\/.+)?$/ ,srpmix-dir-dest)
    ))

(define (pkg-dir-dest path params config)
  (route routing-table (compose-path path) params config))


(provide "yogomacs/dests/pkg-dir")