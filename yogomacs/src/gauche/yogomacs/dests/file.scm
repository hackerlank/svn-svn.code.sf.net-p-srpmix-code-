(define-module yogomacs.dests.file
  (export file-dest
	  fix-css-href
	  integrate-file-face)
  (use srfi-1)
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
  (use yogomacs.domain)
  ;;
  (use sxml.sxpath)
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
      (fundamental real-src-file 
		   (config 'fundamental-mode-line-threshold)
		   (config 'fundamental-mode-column-threshold)
		   config) 
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

(define (file-dest path params config)
  (let* ((last (last path))
	 (head (path->head path))
	 (real-src-dir (build-path (config 'real-sources-dir) head))
	 (real-src-file (build-path real-src-dir last))
	 (file-type (file-type real-src-file)))
    (if (to-domain? real-src-file config)
	(file-dest0 real-src-file file-type (config 'mode) params config)
	(forbidden "Out of domain" real-src-file))))

(define-macro (guard-with-asis real-src-file config . body)
  `(guard (e (else (receive (asis last-modified-time)
		       (asis ,real-src-file ,config)
		     (make-asis-data asis last-modified-time))))
     ,@body))

(define (file-dest0 real-src-file file-type mode params config)
  (define (make-shtml-data shtml last-modified-time)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose fix-css-href integrate-file-face) shtml)
      :last-modification-time last-modified-time))
  (define (make-asis-data asis last-modified-time)
    (make <asis-data> 
      :params params
      :config config
      :data asis
      :last-modification-time last-modified-time
      :mime-type (apply format "~a/~a" file-type)))
  (cond
   ((not (equal? (car file-type) "text"))
    (if (eq? mode 'cache-build)
	(make <empty-data>)
	(receive (asis last-modified-time)
	    (asis real-src-file config)
	  (make-asis-data asis last-modified-time)
	  )))
   ((eq? mode 'cache-build)
    (unwind-protect
     (retrieve-shtml real-src-file config)
     (make <empty-data>)))
   ((eq? mode 'read-only)
    (guard-with-asis 
     real-src-file config
     (receive (shtml last-modified-time) 
	 (cache real-src-file #f "shtml" #f config)
       (if shtml
	   (make-shtml-data shtml last-modified-time)
	   (receive (shtml last-modified-time)
	       (fundamental real-src-file 0 0 config)
	     (make-shtml-data shtml last-modified-time))))))
   ((eq? mode 'stand-alone)
    (guard-with-asis 
     real-src-file config
     (receive (shtml last-modified-time) 
	 (retrieve-shtml real-src-file config)
       (make-shtml-data shtml last-modified-time))))
   (else
    (errorf "Unknown mode: ~s" mode))))

(provide "yogomacs/dests/file")
