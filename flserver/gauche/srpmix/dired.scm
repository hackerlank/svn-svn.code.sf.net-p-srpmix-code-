(define-module srpmix.dired
  (use srfi-1)
  (use srfi-13)
  (use srfi-27)


  (use file.util)

  (use text.html-lite)
  (use www.cgi)

  (use srpmix.config)


  (export run-dired)
  )
(select-module srpmix.dired)

(random-source-randomize! default-random-source)

(define css  "<!-- 
      body { 
        color: #ffffff; 
        background-color: #000000; 
      } 
 
      a { 
        color: inherit; 
        background-color: inherit; 
        font: inherit; 
        text-decoration: inherit; 
      } 
      a:hover { 
        /* text-decoration: underline; */
        background-color: darkolivegreen;
      } 

      .dired-header {
        /* dired-header */
        color: palegreen;
      }
      .dired-directory {
        /* dired-directory */
        color: #0000ff;
        font-weight: bold;
      }

      .dired-marked {
        /* dired-marked */
        color: magenta;
      }

      .dired-symlink {
        /* dired-symlink */
        color: cyan;
        font-weight: bold;
      }
    -->")

;; TODO: Embed hrefs
(define (build-header path-in-chroot)
  (list
   (html:span :class "dired-header" (format "  ~a" path-in-chroot))
   ":"
   "\n"
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
      (html-escape-string (format "http://srpmix.org/api/browse.cgi?path=~a&display=~a"
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
		    (format "~a ~a------rwx n sources srpmix 4096  1974-01-01 00:00 "
			    marker
			    (if dir? "d" "-"))
		    (html:a :href href ee)
		    "\n")))
     (else
      (list
       (format "  ~a------rwx n sources srpmix 4096  1974-01-01 00:00 "
	       (if dir? "d" "-"))
       (html:a :href href
	       (cond
		(symlink? (html:span 
			   :class "dired-symlink" 
			   (string-append ee " -> " (html-escape-string symlink?))))
		(dir? (html:span 
		       :class "dired-directory"
		       ee))
		(else ee))
	       "\n"))))))

(define (run-dired path err-return)
  
  (let ((files (directory-list path :add-path? #f :children? #t
			       :filter  (lambda (e) 
					  (and (not (equal? e ".htaccess"))
					       (if (equal? path prefix)
						   (member e top-entries)
						   #t)))))
	(path-in-chroot (string-append "/" (wash-path (string-drop path (string-length prefix))))))
    (list (cgi-header)
	  (html-doctype)
	  (html:html
	   (html:head
	    (html:title  path-in-chroot)
	    (html:style :type "text/css"
			css
			))

	   (html:body
	    (html:pre 
	     (list
	      (build-header (html-escape-string path-in-chroot))

	      (build-line "." #t #f (href-for path  "." "font-lock" err-return)   #f)
	      (build-line ".." #t #f (href-for path  ".." "font-lock" err-return) #f)
	      
	      (map (lambda (e)
		     (let* ((epath (build-path path e))
			    (dir? (file-is-directory? epath)))
		       (cond
			((equal? e "STATUS")
			 (build-line e dir? 
				     (call-with-input-file epath
				       (lambda (port)
					 (if (equal? (port->string port) "0\n")
					     #f
					     "D")))
				     (href-for path e "font-lock" err-return) #f)
			 )
			
			(else
			 (let1 symlink (symlink-for path e)
			     (build-line e dir? #f (href-for path e 
							     (if (< max-font-lock-size 
								    (file-size epath))
								 "raw"
								 "font-lock")
							     err-return) symlink))
			 ))))
		   files))))))))

(provide "srpmix/dired")