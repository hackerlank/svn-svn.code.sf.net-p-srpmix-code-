(define-module yogomacs.dests.file
  (export file-dest
	  fix-css-href
	  integrate-file-face)
  (use srfi-1)
  (use www.cgi)  
  (use file.util)
  ;;
  (use yogomacs.fix)
  (use yogomacs.path)
  (use yogomacs.reply)
  ;;
  (use yogomacs.renderers.find-file)
  (use yogomacs.renderers.syntax)
  (use yogomacs.renderers.cache)
  (use yogomacs.renderers.asis)
  ;;
  (use yogomacs.dests.css)
  ;;
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

(define (file-dest path params config)
  (let* ((last (last path))
	 (head (path->head path))
	 (real-src-dir (build-path (config 'real-sources-dir) head))
	 (real-src-file (build-path real-src-dir last)))
    (if #t
	(let1 mime-type "text/plain"
	  (make <asis-data> 
	    :data (asis real-src-file mime-type config)
	    :mime-type mime-type))
	(list
	 (cgi-header)
	 (fix
	  (cache real-src-file syntax "shtml" config)
	  fix-css-href
	  integrate-file-face)))))


(provide "yogomacs/dests/file")
