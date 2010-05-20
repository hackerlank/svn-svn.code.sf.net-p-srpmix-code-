(define-module yogomacs.dired
  (use srfi-1)
  (use srfi-13)
  (use srfi-27)


  (use file.util)

  (use text.html-lite)
  (use www.cgi)
  (use rfc.uri)

  (use yogomacs.config)
  (use yogomacs.cssize)
  (use yogomacs.yogomacs)

  (export run-dired)
  )
(select-module yogomacs.dired)

(random-source-randomize! default-random-source)

(define faces '(
		default
		;;
		highlight
		;;
		linum
		fringe
		;;
		dired-header
		dired-directory
		dired-marked
		dired-symlink
		dired-perm-write
		;;
		))

;; TODO: Embed hrefs
(define (build-dired-header path-in-chroot ofiles)
  (list
   (linum 1 ofiles) (fringe ".yogomacs_dired_header")
   (html:span :class "dired-header" (format "  ~a" path-in-chroot))
   ":"
   "\n"
   (linum 2 ofiles) (fringe ".yogomacs_dired_total_line")
   (format "  total used in directory ~d available 1152921504606846976\n"
	   (+ 27 (random-integer 87))
	   )))

(define (wash-path path)
  (let1 path (if (string-prefix? "/" path)
		 (substring path 1 -1)
		 path)
    (if (string-suffix? "/" path)
	(wash-path (substring path 0 (- (string-length path) 1)))
	path)))

(define (href-for dir entry display err-return)
  (let ((path (simplify-path (build-path dir entry)))
	(prefix-length (string-length prefix)))
    (cond
     ((string-prefix? prefix path)
      (uri-compose :scheme "http" :host host
		   :path  (format "/api/browse.cgi?path=~a&display=~a"
				  (wash-path (string-drop path prefix-length))
				  display)))
     (else
      (href-for prefix "." display err-return)))))

(define (symlink-for path entry)
  (let1 path (build-path path entry)
    (if (file-is-symlink? path)
	(let1 link (sys-readlink path)
	  (string-append "/" (let loop ((path link))
			       (if (string-prefix? "../" path)
				   (loop (string-drop path 3))
				   path))))
	#f)))

(define (build-line entry dir? marker href symlink?)
  (let1 ee (html-escape-string entry)
	(cond
	 (marker
	  (html:span :class "dired-marked"
		     (list
		      (format #;"~a ~a------rwx n sources yogomacs 4096  1983-09-27 12:35 "
		       "~a ~arms n sources yogomacs 4096  1983-09-27 12:35 " 
		       marker (if dir? "d" "-"))
		      (if href
			  (html:a :href href ee)
			  ee)
		      "\n")))
	 (else
	  (list
	   (format #;"  ~a------rwx n sources yogomacs 4096  1983-09-27 12:35 "
	    "  ~arms n sources yogomacs 4096  1983-09-27 12:35 "
	    (if dir? "d" "-"))
	   (let1 line (cond
		       (symlink? (html:span 
				  :class "dired-symlink" 
				  (string-append ee " -> " (html-escape-string symlink?))))
		       (dir? (html:span 
			      :class "dired-directory"
			      ee))
		       (else ee))
		 (if href
		     (html:a :href href line)
		     line))
	   "\n")))))

(define (build-line-for-real-entry e i path ofiles err-return)
  (let* ((epath (build-path path e))
	 (dir? (file-is-directory? epath)))
    (cond
     ((equal? e "STATUS")
      (list (linum (i) ofiles) (fringe e)
	    (build-line e dir? 
			(call-with-input-file epath
			  (lambda (port)
			    (if (equal? (port->string port) "0\n")
				#f
				"D")))
			(href-for path e "font-lock" err-return) #f))
      )
     ((not (file-is-readable? epath))
      (list (linum (i) ofiles) (fringe e)
	    (build-line e dir? "D" #f #f)))
     (else
      (let1 symlink (symlink-for path e)
	(list (linum (i) ofiles) (fringe e) 
	      (build-line e dir? #f (href-for path e 
					      (if (< max-font-lock-size 
						     (file-size epath))
						  "raw"
						  "font-lock")
					      err-return) symlink)))
      ))))

(define (linum i ofiles)
  (html:span :class "linum"
	     :id    (format "linum:~a" i)
	     (let1 istr (x->string i)
	       (string-append 
		(make-string (- ofiles (string-length istr)) #\space)
		istr
		"")
	     )))

(define (fringe name)
  (html:span :class "fringe"
	     :id    (format "name:~a" name)
	     " "))

(define (css-link-for-face f err-return)
  (cssize f err-return)
  (list (html:link :rel "stylesheet" 
		   :type "text/css"
		   :href (string-append css-url "/" (file-for-face f)))
	"\n"))

(define (run-dired path err-return)
  (let* ((files (directory-list path :add-path? #f :children? #t
				:filter  (lambda (e) 
					   (and (not (equal? e ".htaccess"))
						(if (equal? path prefix)
						    (member e top-entries)
						    #t)))))
	 (ofiles (string-length (x->string (+ (length files) 
					      1 ; header
					      1 ; total line
					      1 ; .
					      1 ; ..
					      ))))
	 (path-in-chroot (string-append "/" (wash-path (string-drop path (string-length prefix)))))
	 (i (let1 counter 3
	      (lambda ()
		(let1 v counter
		  (set! counter (+ 1 counter))
		  v)))))
    
    (list (cgi-header)
	  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	  (html-doctype :type :xhtml-1.0)
	  (html:html :xmlns  "http://www.w3.org/1999/xhtml" :xml:lang "en" :lang "en"
		     (html:head
		      (list 
		       (html:title  path-in-chroot)
		       (map (cute css-link-for-face <> err-return) faces)
		       ))
		     (html:body
		      (list
		       ;;
		       (install-yogomacs)
		       ;;
		       (html:pre 
			(list
			 (build-dired-header (html-escape-string path-in-chroot) ofiles)

			 (linum (i) ofiles) (fringe ".")
			 (build-line "." #t #f (href-for path  "." "font-lock" err-return)   #f)

			 (linum (i) ofiles) (fringe "..")
			 (build-line ".." #t #f (href-for path  ".." "font-lock" err-return) #f)
			 
			 ;; i path err-return
			 (map (cute build-line-for-real-entry <> i path ofiles err-return)
			      files)))
		       ;;
		       (yogomacs-message)
		       ;;
		       ))))))

(provide "yogomacs/dired")
