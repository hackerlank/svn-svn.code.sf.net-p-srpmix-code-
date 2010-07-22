(define-module yogomacs.dests.packages-dir
  (export packages-dir-dest)
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
(select-module yogomacs.dests.packages-dir)

(define (dest path params config)
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
  (let1 packages-srpmix-dir-dest (srpmix-dir-make-dest 
				  "^/packages/[0-9a-zA-Z]/[^/]+/[^/]+")
    `(
      (#/^\/packages$/ ,dir-dest)
      (#/^\/packages\/[0-9a-zA-Z]+$/ ,dir-dest)
      (#/^\/packages\/[0-9a-zA-Z]+\/[^\/]+$/ ,dest)
      (#/^\/packages\/[0-9a-zA-Z]+\/[^\/]+\/[^\/]+$/ ,packages-srpmix-dir-dest)
      (#/^\/packages\/[0-9a-zA-Z]+\/[^\/]+\/[^\/]+\/.*/ ,packages-srpmix-dir-dest)b
      )))

(define (packages-dir-dest path params config)
  (route routing-table (compose-path path) params config))

(provide "yogomacs/dests/packages-dir")