(define-module yogomacs.dests.dists-dir
  (export dists-dir-dest)
  ;;
  (use srfi-1)
  (use file.util)
  ;;
  (use yogomacs.route)
  (use yogomacs.path)
  (use yogomacs.dests.dir)
  (use yogomacs.dests.pkg-dir)
  (use yogomacs.dests.srpmix-dir)
  (use yogomacs.dests.file)
  ;;
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)
  (use yogomacs.path)
  ;;
  )

(select-module yogomacs.dests.dists-dir)

(define (dists-dir-dest0 path params config)
  ;; TODO: This let should be part of util. 
  (let* ((last (last path))
	 (head (path->head path))
	 (here (lambda (root e) 
		 (build-path root 
			     head
			     last
			     (if (string? e)
				 e
				 (dname-of e)))))
	 (tangle (lambda (e)
		   (sys-basename 
		    (sys-readlink
		     (sys-readlink
		      (path-of e)))))))
    (dir-dest path params config
	      `((#/\.alternatives$/ #f #f)
		(#/^\^.*$/ #t 
			   ,(lambda (e)
			      (here "/" e))
			   ,(lambda (e)
			      (guard (e (else #f))
				     (let1 base (tangle e)
				       base)))
			   ,(lambda (e)
			      (guard (e (else #f))
				     (let1 base (tangle e)
				       (here "/" base))
			   )))))))

(define (dest path params config)
  (dir-dest path params config
	    '((#/^plugins$/ #f #f))))

(define (charhash-dest path params config)
  (let1 get-pkg dname-of
    (dir-dest path params config
	      `((#/^[0-9a-zA-Z].*$/ 
		    #t 
		    ,(pa$ dir-make-url path)
		    ,dir-make-arrowy-to-dname
		    ,(pa$ dir-make-arrowy-to-url
			  get-pkg))))))

(define routing-table
  (let1 dists-srpmix-dir-dest (srpmix-dir-make-dest 
			       "^/dists/[^/]+/packages/[0-9a-zA-Z]/([^/]+)")
    `(
      (#/^\/dists$/ ,dists-dir-dest0)
      (#/^\/dists\/[^\/]+$/ ,dest)
      ;; TODO: Use asis renderer
      (#/^\/dists\/[^\/]+\/dist-mapping\.es/ ,file-dest) 
      (#/^\/dists\/[^\/]+\/packages$/ ,dir-dest)
      (#/^\/dists\/[^\/]+\/packages\/[0-9a-zA-Z]$/ ,charhash-dest)
      (#/^\/dists\/[^\/]+\/packages\/[0-9a-zA-Z]\/[^\/]+$/ ,dists-srpmix-dir-dest)
      (#/^\/dists\/[^\/]+\/packages\/[0-9a-zA-Z]\/[^\/]+\/.*/ ,dists-srpmix-dir-dest)
      )))

(define (dists-dir-dest path params config)
  (route routing-table (compose-path path) params config))

(provide "yogomacs/dests/dists-dir")