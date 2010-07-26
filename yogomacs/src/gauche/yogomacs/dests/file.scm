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
  (use yogomacs.renderers.fundamental)
  ;;
  (use yogomacs.dests.css)
  ;;
  (use yogomacs.rearranges.css-href)
  (use yogomacs.rearranges.face-integrates)
  ;;
  (use gauche.process)
  (use yogomacs.access)
  (use yogomacs.error)
  ;;
  (use sxml.sxpath)
  ;;
  (use font-lock.rearrange.range)
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

(define (retrieve-shtml real-src-file config)
  (receive (shtml last-modified-time)
      (fundamental real-src-file (config 'fundamental-mode-threshold) config) 
    (if shtml
	(values shtml last-modified-time)
	(receive (shtml last-modified-time) 
	    (cache real-src-file find-file "shtml" #f config)
	  (if (and shtml
		   (let1 q (if-car-sxpath '(// 
					    head
					    meta
					    (@ (name (equal? "major-mode")))
					    content 
					    *text*))
		     (member (q shtml) '("fundamental-mode"))))
	      (cache real-src-file syntax "shtml" #t config)
	      (values shtml last-modified-time))))))

(define (make-narrow-down params)
  (or (and-let* ((range-string (cgi-get-parameter "range" params :default #f))
		 (range (guard (e (else #f
					)) 
			  (parse-range range-string))))
	(cute rearrange-range <> (car range) (cdr range)))
      (lambda (shtml) shtml)))

(define (file-dest path params config)
   (let* ((last (last path))
	  (head (path->head path))
	  (real-src-dir (build-path (config 'real-sources-dir) head))
	  (real-src-file (build-path real-src-dir last))
	  (file-type (file-type real-src-file))
	  (narrow-down (make-narrow-down params))
	  
	  )
      (if (equal? (car file-type) "text")
	  (guard (e (else (receive (asis last-modified-time)
			     (asis real-src-file config)
			     (make <asis-data> 
				   :params params
				   :config config
				   :data asis
				   :last-modification-time last-modified-time
				   :mime-type (apply format "~a/~a" file-type)))))
		 (receive (shtml last-modified-time) 
		    (retrieve-shtml real-src-file config)
		    (make <shtml-data>
			  :params params
			  :config config
			  :data ((compose fix-css-href integrate-file-face narrow-down) shtml)
			  :last-modification-time last-modified-time)))
	  (receive (asis last-modified-time)
	     (asis real-src-file config)
	     (make <asis-data> 
		   :params params
		   :config config
		   :data asis
		   :last-modification-time last-modified-time
		   :mime-type (apply format "~a/~a" file-type))))))

(provide "yogomacs/dests/file")
