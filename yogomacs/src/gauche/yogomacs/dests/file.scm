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
  (use yogomacs.renderers.outlang)
  (use yogomacs.renderers.syntax)
  (use yogomacs.renderers.cache)
  (use yogomacs.renderers.asis)
  (use yogomacs.renderers.fundamental)
  ;;
  (use yogomacs.dests.css)
  ;;
  (use yogomacs.rearranges.css-href)
  (use yogomacs.rearranges.face-integrates)
  (use yogomacs.rearranges.title)
  (use yogomacs.rearranges.normalize-major-mode)
  ;;
  (use gauche.process)
  (use yogomacs.access)
  (use yogomacs.error)
  (use yogomacs.domain)
  ;;
  (use yogomacs.tag)
  (use yogomacs.tags)
  ;;
  (use sxml.sxpath)
  (use yogomacs.config)
  )
(select-module yogomacs.dests.file)

(define fix-css-href (cute rearrange-css-href <>
			   (lambda (css-href)
			     (build-path css-route
					 (sys-basename css-href)))))

(define integrate-file-face
   (cute face-integrates <> #`"file-font-lock-,(version)-,(release)" find-file-faces))


(define (file-type file)
  (if (readable? file)
      (string-split (call-with-input-process 
			`(file --brief --mime-type --dereference ,file)
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

(define (file-dest lpath params config . rest)
  (let* ((last (last lpath))
	 (head (path->head lpath))
	 (real-src-file (get-keyword*
			 :real-src-file rest
			 (make-real-src-path config head last)
			 ))
	 (file-type (file-type real-src-file))
	 (has-tag? (has-tag? real-src-file params config)))
    (if (to-domain? real-src-file config)
	(file-dest0 real-src-file 
		    (compose-path lpath)
		    file-type
		    (config 'mode)
		    has-tag?
		    params
		    config)
	(forbidden "Out of domain" real-src-file))))

(define-macro (guard-with-asis real-src-file config . body)
  `(guard (e (else (receive (asis last-modified-time)
		       (asis ,real-src-file ,config)
		     (make-asis-data asis last-modified-time))))
     ,@body))

(define (file-dest0 real-src-file web-path file-type mode has-tag? params config)
  (define (make-shtml-data shtml last-modified-time)
    (make <shtml-data>
      :params params
      :config config
      :data ((compose 
	      fix-css-href
	      integrate-file-face
	      (cute rearranges-title <> web-path)
	      normalize-major-mode
	      ) shtml)
      :has-tag? has-tag?
      :last-modification-time last-modified-time))
  (define (try-outlang file config)
    (if-let1 shtml (guard (e (else #f))
		     (outlang file config))
	     (make-shtml-data shtml (ref (sys-stat file) 'mtime))
	     #f))
  (define (make-asis-data asis last-modified-time)
    (make <asis-data> 
      :params params
      :config config
      :data asis
      :last-modification-time last-modified-time
      :mime-type (apply format "~a/~a" file-type)
      :has-tag? has-tag?))
  (cond
   ((and (equal? (car file-type) "application")
	 (equal? (cadr file-type) "x-empty"))
    (receive (shtml last-modified-time)
	(fundamental real-src-file 0 0 config)
      (make-shtml-data shtml last-modified-time)))
   ((not (equal? (car file-type) "text"))
    (if (eq? mode 'cache-build)
	(make <empty-data> :has-tag? has-tag?)
	(receive (asis last-modified-time)
	    (asis real-src-file config)
	  (make-asis-data asis last-modified-time)
	  )))
   ((eq? mode 'cache-build)
    (unwind-protect
     (retrieve-shtml real-src-file config)
     (make <empty-data> :has-tag? has-tag?)))
   ((eq? mode 'read-only)
    (or (try-outlang real-src-file config)
	(guard-with-asis 
	 real-src-file config
	 (receive (shtml last-modified-time) 
	     (cache real-src-file #f "shtml" #f config)
	   (if shtml
	       (make-shtml-data shtml last-modified-time)
	       (receive (shtml last-modified-time)
		   (fundamental real-src-file 0 0 config)
		 (make-shtml-data shtml last-modified-time)))))))
   ((eq? mode 'stand-alone)
    (or (try-outlang real-src-file config)    
	(guard-with-asis 
	 real-src-file config
	 (receive (shtml last-modified-time) 
	     (retrieve-shtml real-src-file config)
	   (make-shtml-data shtml last-modified-time)))))
   (else
    (errorf "Unknown mode: ~s" mode))))

(provide "yogomacs/dests/file")
