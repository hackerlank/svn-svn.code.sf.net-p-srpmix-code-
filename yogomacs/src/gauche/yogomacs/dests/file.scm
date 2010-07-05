(define-module yogomacs.dests.file
  (export file-dest
	  fix-css-href)
  (use srfi-1)
  (use www.cgi)  
  (use file.util)
  ;;
  (use yogomacs.path)
  ;;
  (use yogomacs.flserver)
  (use font-lock.flclient)
  ;;
  (use yogomacs.fix)
  (use yogomacs.caches.css)
  ;;
  (use yogomacs.dests.debug)
  (use yogomacs.dests.css)
  (use yogomacs.rearranges.css-href)
  (use yogomacs.rearranges.css-integrates)
  )
(select-module yogomacs.dests.file)


(define fix-css-href (cute rearrange-css-href <>
			   (lambda (css-href)
			     (build-path css-route (sys-basename css-href)))))

(define (file-dest path params config)
  (let* ((last (last path))
	 (head (path->head path))
	 (real-src-dir (build-path (config 'real-sources-dir) head))
	 ;; cache
	 (real-dest-path (build-path "/tmp" (format "~a.~a" last "shtml")))
	 (shtmlize (pa$ flclient-shtmlize
			(build-path real-src-dir last)
			real-dest-path
			(css-cache-dir config)
			:verbose (config 'client-verbose))))
    (flserver shtmlize config)
    (if (file-exists? real-dest-path)
	(list
	 (cgi-header)
	 (fix
	  (call-with-input-file real-dest-path read)
	  fix-css-href
	  
	  ))
	(print-echo path path config "Flserver Rendering Timeout"))))


(provide "yogomacs/dests/file")
