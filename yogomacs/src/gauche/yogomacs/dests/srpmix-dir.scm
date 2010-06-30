(define-module yogomacs.dests.srpmix-dir
  (export srpmix-dir-dest)
  (use yogomacs.route)
  (use yogomacs.path)
  (use yogomacs.dests.dir)
  (use yogomacs.access)
  (use srfi-1)
  ;;
  (use file.util)
  (use www.cgi)
  (use yogomacs.dests.debug)
  (use yogomacs.flserver)
  (use font-lock.flclient)
  (use yogomacs.caches.css)
  (use yogomacs.render)
  (use font-lock.rearrange.css-href)
  (use yogomacs.dests.css)
  )
(select-module yogomacs.dests.srpmix-dir)

(define (dest path params config)
  (dir-dest path params config
	       '((#/^plugins$/ #f #f)
		 (#/^vanilla$/ #f #f))))

(define (file-and-dir-dest path params config)
  (let* ((last (last path))
	 (head (path->head path))
	 (real-src-dir (build-path (cdr (assq 'real-sources-dir config)) head)))
    (if (readable? real-src-dir last)
	(if (directory? real-src-dir last)
	    (dir-dest path params config)
	    (let* ((real-dest-path (build-path "/tmp" (format "~a.~a" last "shtml")))
		   (shtmlize (pa$ flclient-shtmlize
				  (build-path real-src-dir last)
				  real-dest-path
				  (css-cache-dir config)
				  :verbose (cdr (assq 'client-verbose config)))))
	      (flserver shtmlize config)
	      (if (file-exists? real-dest-path)
		  (list
		   (cgi-header)
		   (render
		    (rearrange-css-href 
		     (call-with-input-file real-dest-path read)
		     (lambda (css-href)
		       (build-path css-route (sys-basename css-href))))))
		  (print-echo path path config "FALSE!")
		  )
	      ))
	(cgi-header :status "404 Not Found"))))

(define routing-table
  `((#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)$/               ,dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/pre-build$/    ,dir-dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/pre-build\/.*/ ,file-and-dir-dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/archives$/     ,dir-dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/archives\/.*/  ,file-and-dir-dest)
    ;; (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+/([^^\/]+)\/vanilla$/ ,dir-dest)
    ))

(define (srpmix-dir-dest path params config)
  (route routing-table (compose-path path) params config))

(provide "yogomacs/dests/srpmix-dir")