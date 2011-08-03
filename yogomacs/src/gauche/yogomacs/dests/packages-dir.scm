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
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)
  ;;
  )
(select-module yogomacs.dests.packages-dir)

(define (dest path params config)
  (let1 get-pkg (lambda (_)
		  (car (reverse path)))
    (dir-dest path params config
	      `((#/^[0-9a-zA-Z].*$/ 
		    #t 
		    ,(pa$ dir-make-url path)
		    ,dir-make-arrowy-to-dname
		    ,(pa$ dir-make-arrowy-to-url
			  get-pkg)
		    )))))

(define routing-table
  (let1 packages-srpmix-dir-dest (srpmix-dir-make-dest 
				  "^/packages/[0-9a-zA-Z]/[^/]+/[^/]+")
    `(
      (#/^\/packages$/ ,dir-dest)
      (#/^\/packages\/[0-9a-zA-Z]+$/ ,dir-dest)
      (#/^\/packages\/[0-9a-zA-Z]+\/[^\/]+$/ ,dest)
      (#/^\/packages\/[0-9a-zA-Z]+\/[^\/]+\/[^\/]+$/ ,packages-srpmix-dir-dest)
      (#/^\/packages\/[0-9a-zA-Z]+\/[^\/]+\/[^\/]+\/.*/ ,packages-srpmix-dir-dest)
      )))

(define (packages-dir-dest path params config)
  (route routing-table (compose-path path) params config))

(provide "yogomacs/dests/packages-dir")