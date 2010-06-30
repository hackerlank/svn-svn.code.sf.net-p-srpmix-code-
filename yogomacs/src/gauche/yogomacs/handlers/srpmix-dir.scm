(define-module yogomacs.handlers.srpmix-dir
  (export srpmix-dir-handler)
  (use yogomacs.route)
  (use yogomacs.path)
  (use yogomacs.handlers.dir)
  (use yogomacs.access)
  (use srfi-1)
  ;;
  (use file.util)
  (use www.cgi)
  (use yogomacs.handlers.debug)
  (use yogomacs.flserver)
  (use font-lock.flclient)
  (use yogomacs.css-cache)
  (use yogomacs.render)
  (use font-lock.rearrange.css-href)
  )
(select-module yogomacs.handlers.srpmix-dir)

(define (handler path params config)
  (dir-handler path params config
	       '((#/^plugins$/ #f #f)
		 (#/^vanilla$/ #f #f))))

(define (file-handler path params config)
  (let* ((last (last path))
	 (head (path->head path))
	 (real-src-dir (build-path (cdr (assq 'real-sources-dir config)) head)))
    (if (readable? real-src-dir last)
	(if (directory? real-src-dir last)
	    (dir-handler path params config)
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
		       (build-path "/web/css" (sys-basename css-href))))))
		  (print-echo path path config "FALSE!")
		  )
	      ))
	(cgi-header :status "404 Not Found"))))

(define routing-table
  `((#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)$/               ,handler)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/pre-build$/    ,dir-handler)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/pre-build\/.*/ ,file-and-dir-handler)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/archives$/     ,file-and-dir-handler)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)\/archives\/.*/  ,file-handler)
    ;; (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+/([^^\/]+)\/vanilla$/ ,dir-handler)
    ))

(define (srpmix-dir-handler path params config)
  (route routing-table (compose-path path) params config))

(provide "yogomacs/handlers/srpmix-dir")