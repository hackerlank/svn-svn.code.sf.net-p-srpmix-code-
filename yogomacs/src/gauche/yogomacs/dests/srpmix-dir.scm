(define-module yogomacs.dests.srpmix-dir
  (export srpmix-dir-dest
	  srpmix-dir-make-dest
	  )
  (use yogomacs.route)
  (use yogomacs.path)
  (use yogomacs.dests.fs)
  (use yogomacs.dests.dir)
  (use yogomacs.dests.file)
  (use yogomacs.access)
  (use srfi-1)
  ;;
  (use file.util)
  (use www.cgi)
  (use yogomacs.dests.debug)
  (use yogomacs.storages.css)
  (use yogomacs.dests.css)
  )
(select-module yogomacs.dests.srpmix-dir)

(define (dest path params config)
  (dir-dest path params config
	    `((#/^plugins$/ #f #f)
	      (#/^vanilla$/ #t
			    ,(pa$ dir-make-url path)
			    ,"./vanilla" ; ???
			    ))))

(define (srpmix-dir-make-routing-table prefix)
   `((,(string->regexp (string-append prefix "$")) ,dest)
     (,(string->regexp (string-append prefix "/pre-build$")) ,dir-dest)
     (,(string->regexp (string-append prefix "/pre-build/.*")) ,fs-dest)
     (,(string->regexp (string-append prefix "/archives$")) ,dir-dest)
     (,(string->regexp (string-append prefix "/archives/.*")) ,fs-dest)
     (,(string->regexp (string-append prefix "/specs.spec$")) ,file-dest)
     (,(string->regexp (string-append prefix "/STATUS$")) ,file-dest)
     (,(string->regexp (string-append prefix "/SRPMIX$")) ,file-dest)
     (,(string->regexp (string-append prefix "/CRADLE$")) ,file-dest)
     (,(string->regexp (string-append prefix "/vanilla$")) ,dir-dest)
     (,(string->regexp (string-append prefix "/vanilla/.*")) ,fs-dest)
     ))

(define (srpmix-dir-make-dest prefix)
  (lambda (path params config)
    (route (srpmix-dir-make-routing-table prefix) (compose-path path) params config)))

(define srpmix-dir-dest (srpmix-dir-make-dest "^/sources/[a-zA-Z0-9]/[^/]+/([^^/]+)"))

(provide "yogomacs/dests/srpmix-dir")