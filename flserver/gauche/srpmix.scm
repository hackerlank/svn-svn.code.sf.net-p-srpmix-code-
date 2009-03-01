(define-module srpmix
  (use text.html-lite)
  (use www.cgi)
  
  (use srfi-1)
  (use srfi-13)

  (use file.util)
  (use util.match)

  (use srpmix.font-lock)
  (use srpmix.dired)
  (use srpmix.config)

  (export 
   check-package
   check-file
   check-version
   check-stage
   check-file-display
   check-dir-display
   check-line
   check-range
   ;;
   params->path
   ;;
   path->html
   ;;
   make-reporter
   )
  )
(select-module srpmix)

;; ---------------------------------------------------------------------
;;
;; Constants
;;
(define dist-prefix (string-append prefix "/" "dists"))
(define sources-prefix (string-append prefix "/" "sources"))

(define socket-dir "/home/masatake/tmp")
(define output-dir "/home/masatake/tmp/flcache")

(define defined-stages  '(pre-build specs))
(define defined-file-displays '(raw font-lock))
(define defined-dir-displays '(raw font-lock))


;; ---------------------------------------------------------------------
;;
;; Parameter Checkers
;;
(define (check-package package err-return)
  (unless (string? package)
    (err-return "No package"))
  (unless (> (string-length package) 0)
    (err-return "No package"))
  (when (or (equal? package ".")
	    (equal? package "..")
	    (string-index package #\/))
    (err-return "No package"))
  package)

(define (check-file file err-return)
  (when (string-scan file "..")
    (err-return "Broken file"))
  (when (string-scan file ".htaccess")
    (err-return "Broken file"))
  file)

(define (check-dir dir err-return)
  (let1 path (simplify-path (build-path prefix dir))
    (unless (string-prefix? prefix path)
      (err-return "Broken dir"))
    path))

(define (check-version version err-return)
  (when (string-scan version "/")
    (err-return "Broken version"))
  (when (string-scan version "..")
    (err-return "Broken verison"))
  verison)

(define (check-stage stage err-return)
  (unless (member (string->symbol stage) defined-stages)
    (err-return (format "Undefined stage: ~s" stage)))
  stage)

(define (check-display display all err-return)
  (unless (member (string->symbol display) all)
    (err-return (format "Undefined display: ~s" display)))
  (string->symbol display))

(define (check-file-display display err-return)
  (check-display display defined-file-displays err-return))
(define (check-dir-display display err-return)
  (check-display display defined-dir-displays err-return))

(define (check-line line err-return)
  (if (string? line)
      (let1 b  (string->number line)
	(unless (and b (integer? b) (< 0 b))
	  (err-return (format "Broken line format: ~s" line)))
	b)
      line))

(define (check-range range err-return)
  (if range
      (let1 splited (string-split range #/-/)
	(unless (and (list? splited) 
		     (eq? (length splited) 2))
	  (err-return (format "Broken range format: ~s" range)))
	(let ((start (check-line (car splited)  err-return))
	      (end   (check-line (cadr splited) err-return)))
	  (unless (< start end)
	    (err-return (format "Broken range format: ~s" range)))
	  (list-tabulate (- end start) (lambda (i) (+ start i))) ))
      range))



;; ---------------------------------------------------------------------
;;
;; Parameters -> Path
;;
(define params->path (match-lambda*
			((dist version package stage file err-return)
			 (if dist
			     (params->path-via-dists dist package stage file err-return)
			     (params->path-via-sources package version stage file err-return)))
			((dir err-return)
			 (let1 path (check-dir dir err-return)
			   (cond
			    ((not (file-is-readable? path))
			     (err-return (format "Target unreadable: ~s" dir)))
			    ((file-is-directory? path)
			     (values path 'dir))
			    ((file-is-regular? path)
			     (values path 'file))
			    (else
			     (err-return (format "No handler for: ~s" dir))))))))


(define (params->path-via-package package-dir stage file err-return)
  (let1 stage-object (string-append package-dir "/" stage)
    (cond
     ((and (file-is-regular? stage-object)
	   (file-is-readable? stage-object))
      (values file 'file))
     (else
      (check-file file err-return)
      (let1 file-object (string-append stage-object "/" file)
	(cond 
	 ((and (file-is-regular? file-object)
	       (file-is-readable? file-object))
	  (values file-object 'file))
	 ((and (file-is-directory? file-object)
	       (file-is-readable? file-object))
	  (values file-object 'dir))
	 (else
	  (err-return (format "Target unreadable: ~s" file-object)))))))))

(define (params->path-via-dists dist package stage file err-return)
  (let ((dists (directory-list dist-prefix :children? #t
			       :filter (lambda (e) (not (equal? e ".htaccess")))
			       )))
    (unless (member dist dists)
      (err-return (format "Unknow dist: ~s" dist))) 
    (let1 dist-dir (string-append dist-prefix "/" dist)
      (let1 package-dir (string-append dist-dir "/" 
				       "packages" "/"
				       (substring package 0 1) "/"
				       package)
	(unless (file-is-directory? package-dir)
	  (err-return (format "No directory for package: ~s" package)))
	(params->path-via-package package-dir stage file err-return)))))
(define (params->path-via-sources package version stage file err-return)
  (let1 package-dir (string-append sources-prefix "/"
				   (substring package 0 1) "/"
				   package)
    (unless (file-is-directory? package-dir)
      (err-return (format "No directory for package: ~s" package)))
    (check-version version err-return)
    (let1 version-dir (string-append package-dir "/"
				     version)
      (unless (file-is-directory? version-dir)
	(err-return (format "No directory for version: ~s" version)))
      (params->path-via-package version-dir stage file err-return))))

;; ---------------------------------------------------------------------
;;
;; Path -> HTML
;;
(define path->html (match-lambda*
		    ((path type line range display err-return)
		     (case display
		       ('raw
			(path->html-as-raw path type line range err-return)
			)
		       ('font-lock
			(path->html-as-font-lock path type line range err-return)
			)))
		    ((path type display err-return)
		     (path->html path type #f #f display err-return))))

(define (path->html-as-raw path type line range err-return)
  (case type
    ('file
     (file->html-as-raw path line range err-return)
     )
    ('dir
     (dir->html-as-raw path err-return)
     )))

(define (file->html-as-raw path line range err-return)
  (let1 head (cgi-header :content-type "text/plain")
    (call-with-input-file path
      (lambda (iport)
	(cond 
	 (line
	  (let1 contents (port->string-list iport)
	    (list head (if (<= line (length contents))
			   (list (list-ref contents (- line 1)) "\n")
			   (err-return "Line: out of range")))))
	 (range
	  (let* ((contents (port->string-list iport))
		 (len      (length contents)))
	    `(,head ,@(map (lambda (i)
			     (if (<= i len)
				 (list (list-ref contents (- i 1)) "\n")
				 (err-return "Range: out of range")
				 ))
			   range))
	    ))
	 (else
	  (list head (port->string iport))))))))

(define (dir->html-as-raw path err-return)
  (cons (cgi-header :content-type "text/plain")
	(map (lambda (elt) (list elt "\n"))
	     (directory-list path :add-path? #f :children? #t
			     :filter  (lambda (e) 
					(and (not (equal? e ".htaccess"))
					     (if (equal? path prefix)
						 (member e top-entries)
						 #t)))))))

(define (path->html-as-font-lock path type line range err-return)
  (case type
    ('file 
     (if line
	 (path->html-as-font-lock path type #f (list line (+ 1 line)) err-return)
	 (file->html-as-font-lock path range err-return)))
    ('dir
     (dir->html-as-font-lock path err-return))))

(define (file->html-as-font-lock path range err-return)
  (font-lock path err-return))

(define (dir->html-as-font-lock path err-return)
  (run-dired path err-return))


(define (make-reporter return)
  (lambda (string)
    (return (list (cgi-header)
		  (html-doctype)
		  (html:html 
		   (html:body 
		    (html:p 
		     (html-escape-string string))))))))


(provide "srpmix")
