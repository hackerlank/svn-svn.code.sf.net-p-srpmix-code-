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
  (use yogomacs.util.lcopy)
  (use srfi-1)
  ;;
  (use file.util)
  (use www.cgi)
  (use yogomacs.dests.debug)
  (use yogomacs.storages.css)
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
     (,(string->regexp (string-append prefix "/pre-build/.*")) ,lcopy-fs-dest)
     (,(string->regexp (string-append prefix "/checkout.lcopy$")) ,file-dest)
     (,(string->regexp (string-append prefix "/STATUS$")) ,file-dest)
     (,(string->regexp (string-append prefix "/LCOPY$")) ,file-dest)
     ;; archives -> cmdline
     ))

(define lcopy-common-prefix "^/sources/[a-zA-Z0-9]/[^/]+/\^lcopy-(?:[^/]+)")
(define lcopy-common-prefix-regexp (string->regexp lcopy-common-prefix))

(define (lcopy-fs-dest path params config)
  (let1 composed-path (compose-path path)
    (let1 match (lcopy-common-prefix-regexp composed-path)
      (cond
       ((and match
	     (lcopy-dir->no-update? (string-append (config 'real-sources-dir) (match 0))))
	(fs-dest path params config))
       (else
	(fs-dest-read-only path params config))))))

(define (lcopy-dir-make-dest prefix)
  (lambda (path params config)
    (route (lcopy-dir-make-routing-table prefix) 
	   (compose-path path)
	   params
	   config)))

(define lcopy-dir-dest (lcopy-dir-make-dest lcopy-common-prefix))

(provide "yogomacs/dests/lcopy-dir")