(define-module yogomacs.dests.file
  (export file-dest
	  fix-css-href
	  integrate-file-face)
  (use srfi-1)
  (use www.cgi)  
  (use file.util)
  ;;
  (use yogomacs.path)
  ;;
  (use yogomacs.renderer)
  (use yogomacs.renderers.find-file)
  (use yogomacs.renderers.syntax)
  (use yogomacs.renderers.cache)
  ;;
  (use yogomacs.fix)
  ;;
  (use yogomacs.dests.debug)
  (use yogomacs.dests.css)
  (use yogomacs.rearranges.css-href)
  (use yogomacs.rearranges.face-integrates)
  )
(select-module yogomacs.dests.file)

(define fix-css-href (cute rearrange-css-href <>
			   (lambda (css-href)
			     (build-path css-route
					 (sys-basename css-href)))))

(define integrate-file-face
   (cute face-integrates <> "file-font-lock" find-file-faces))

(define (log msg)
  (print msg (current-error-port)))

(define (file-dest path params config)
  (let* ((last (last path))
	 (head (path->head path))
	 (real-src-dir (build-path (config 'real-sources-dir) head))
	 (real-src-file (build-path real-src-dir last)))
    (guard (e
	    ((<renderer-error> e) 
	     (log (condition-ref e 'log))
	     (list
	      (cgi-header :status (condition-ref e 'status))
	      (print-echo0 path path config (condition-ref e 'message))))
	    ((<error> e)
	     (list
	      (cgi-header :status "502 Bad Gateway")
	      (print-echo0 path path config (condition-ref e 'message))))
	    #;(else
	     (list
	      (cgi-header :status "500 Internal Server Error")))
	    )
	   (list
	    (cgi-header)
	    (fix
	     ;(cache real-src-file find-file "shtml" config)
	     (cache real-src-file syntax "shtml" config)
	     fix-css-href
	     integrate-file-face)))))

(provide "yogomacs/dests/file")
