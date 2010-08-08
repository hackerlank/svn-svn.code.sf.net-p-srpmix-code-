(define-module yogomacs.dests.lcopy-dir
  (export lcopy-dir-dest
	  lcopy-dir-make-dest
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
  (use yogomacs.caches.css)
  (use yogomacs.dests.css)
  )
(select-module yogomacs.dests.lcopy-dir)

(define (dest path params config)
  (dir-dest path params config
	    `((#/^plugins$/ #f #f)
	      (#/^archives$/ #f #f)
	      (#/^vanilla$/ #f #f))))

(define (lcopy-dir-make-routing-table prefix)
   `((,(string->regexp (string-append prefix "$")) ,dest)
     (,(string->regexp (string-append prefix "/pre-build$")) ,dir-dest)
     (,(string->regexp (string-append prefix "/pre-build/.*")) ,fs-dest-read-only)
     (,(string->regexp (string-append prefix "/checkout.lcopy$")) ,file-dest)
     (,(string->regexp (string-append prefix "/STATUS$")) ,file-dest)
     (,(string->regexp (string-append prefix "/LCOPY$")) ,file-dest)
     ;; archives -> cmdline
     ))

(define (lcopy-dir-make-dest prefix)
  (lambda (path params config)
    (route (lcopy-dir-make-routing-table prefix) (compose-path path) params config)))

(define lcopy-dir-dest (lcopy-dir-make-dest "^/sources/[a-zA-Z0-9]/[^/]+/\^lcopy-([^/]+)"))

(provide "yogomacs/dests/lcopy-dir")