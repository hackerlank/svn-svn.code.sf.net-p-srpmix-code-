(define-module yogomacs.dests.file
  (export file-dest
	  fix-css-href
	  integrate-file-face)
  (use srfi-1)
  (use www.cgi)  
  (use file.util)
  ;;
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
  ;;
  (use gauche.process)
  (use yogomacs.access)
  (use yogomacs.error)
  )
(select-module yogomacs.dests.file)

(define fix-css-href (cute rearrange-css-href <>
			   (lambda (css-href)
			     (build-path css-route
					 (sys-basename css-href)))))

(define integrate-file-face
   (cute face-integrates <> "file-font-lock" find-file-faces))


(define (file-type file)
  (if (readable? file)
      (string-split (call-with-input-process 
			`(file --brief --mime-type ,file)
		      read-line)
		    #\/)
      (not-found "File not redable"
		 file)))

(define (file-dest path params config)
  (let* ((last (last path))
	 (head (path->head path))
	 (real-src-dir (build-path (config 'real-sources-dir) head))
	 (real-src-file (build-path real-src-dir last))
	 (file-type (file-type real-src-file)))
    (if (equal? (car file-type) "text")
	(receive (shtml last-modified-time) 
	    (cache real-src-file find-file "shtml" config)
	  (make <shtml-data>
	    :data ((compose fix-css-href integrate-file-face) shtml)
	    :last-modification-time last-modified-time))
	(receive (asis last-modified-time)
	    (asis (asis real-src-file config))
	  (make <asis-data> 
	    :data asis
	    :last-modification-time last-modified-time
	    :mime-type (apply format "~a/~a" file-type))))))

(provide "yogomacs/dests/file")
