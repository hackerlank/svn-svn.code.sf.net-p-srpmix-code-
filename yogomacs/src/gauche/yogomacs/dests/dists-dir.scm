(define-module yogomacs.dests.dists-dir
  (export dists-dir-dest)
  ;;
  (use yogomacs.route)
  (use yogomacs.path)
  (use yogomacs.dests.dir)
  (use yogomacs.dests.pkg-dir)
  (use yogomacs.dests.srpmix-dir)
  (use yogomacs.dests.file)
  ;;
  (use file.util)
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)
  (use yogomacs.path)
  ;;
  )
(select-module yogomacs.dests.dists-dir)

(define (dest path params config)
  (dir-dest path params config
	    '((#/^plugins$/ #f #f))))

(define (charhash-dest path params config)
  (dir-dest path params config
	    `((#/^[0-9a-zA-Z].*$/ 
		  #t 
		  ,(lambda (e) 
		     (let1 entry-path (path-of e)
		       (if (file-is-readable? entry-path)
			   (compose-path* path (dname-of e))
			   #f)))
		  ,(lambda (e) 
		     (let1 entry-path (path-of e)
		       (guard (e
			       (else #f))
			      (sys-basename (sys-readlink entry-path))))
		     )))))

(define routing-table
  (let1 dists-srpmix-dir-dest (srpmix-dir-make-dest 
			       "^/dists/[^/]+/packages/[0-9a-zA-Z]/([^/]+)")
    `(
      (#/^\/dists$/ ,dir-dest)
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