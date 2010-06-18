;; * Directory
;;
;;   directory -> sxml -> html
;;      <=========> yogomacs.dired
;;                 <======> shtml->html (font-lock)
;;
;;
;; * File
;;
;;   file -> sxml -> gzip -> sxml [-> narrowed sxml] -> html
;;     <=======> xhtmlize (font-lock)
;;             <======> rfc.zlib
;;                    <========> rfc.zlib
;;                             <============> shtml->html (font-lock)
;;                             <=========================> shtml->html (font-lock)

;; . -> /srv/sources...
;; .. -> /srv/sources...
;; http://planet.plt-scheme.org/package-source/lizorkin/ssax.plt/2/0/SXML-tree-trans.ss
(define-module yogomacs.dired
  (export dired
	  dired-faces)
  (use file.util)
  (use util.combinations)
  (use gauche.sequence)
  (use srfi-19)
  )
(select-module yogomacs.dired)

(define dired-faces '(
		      default
		      highlight
		      linum
		      lfringe
		      rfringe
		      dired-regular	;TODO
		      dired-header
		      dired-directory
		      dired-symlink
		      dired-symlink-arrow ;TODO
		      dired-symlink-to	  ;TODO
		      dired-entry-type	  ;TODO
		      dired-size	  ;TODO
		      dired-date	  ;TODO
		      ))
(define dired-styles '(Default Invert))

(define (face->css-url face style css-prefix)
  (format "~a/~a--~a.css" css-prefix face style))

(define (stylesheets css-prefix)
  (reverse
   (fold
    (lambda (face-style result)
      (cons "\n" (cons `(link (|@| 
			       (rel "stylesheet")
			       (type "text/css")
			       (href ,(face->css-url (car face-style) (cadr face-style) css-prefix))
			       (title ,(x->string (cadr face-style)))
			       )) (cons "	" result)))
      )
    (list)
    (cartesian-product `(,dired-faces
			 ,dired-styles )))))

(define (entry-directory path dir entry make-url)
  `(
    (span (|@| (class "dired-directory")) 
	  (a (|@| (href ,(make-url path dir entry 'current-directory)))
	     ,entry))
    "\n"
    ))

(define (entry-symlink path dir entry make-url make-symlink-to)
  `(
    (span (|@| (class "dired-symlink"))
	  (a (|@| (href ,(make-url path dir entry 'symlink)))
	     ,entry))
    (span (|@| (class "dired-symlink-arrow"))
	  " -> ")
    (span (|@| (class "dired-symlink-to"))
	  ;; TODO
	  ,(make-symlink-to path))
    "\n"
    ))

(define (entry-regular path dir entry make-url)
  `(
    (span (|@| (class "dired-regular")) 
	  (a (|@| (href ,(make-url path dir entry 'regular)))
	     ,entry))
    "\n"
    ))

(define (linum&fringe entry linum linum-column)
  (let1 id (format "N:~a/L:~a" entry linum)
    `((span (|@| (class "linum") (id ,id))
	    (a (|@| (href ,(format "#~a" id)))
	       ,(format (string-append "~" (number->string linum-column) ",d")
			linum)))
      (span (|@| (class "lfringe") (id ,(format "f:L/N:~a/L:~d" entry linum))) " ")
      (span (|@| (class "rfringe") (id "f:R/L:~d") linum) " "))))

(define (type&size&date stat size-column)
  `(
    " "
    (span (|@| (class "dired-entry-type"))
	   ,(case (ref stat 'type)
	      ('regular  "-")
	      ('directory "d")
	      ('symlink  "l")
	      (else "?")))
    " "
    (span (|@| (class "dired-size"))
	  ,(format (string-append "~" (number->string size-column) ",d")
		   (ref stat 'size)))
    "  "
    (span (|@| (class "dired-date"))
	  ,(date->string (time-utc->date (make-time time-utc 0 (ref stat 'mtime)))
			 "~b ~e ~H:~M ~Y"
			 )
	  )
    "  "
    ))

(define (line dir linum entry linum-column size-column make-url make-symlink-to result)
  (let ((entry (car entry))
	(path (cadr entry))
	(stat (caddr entry)))
    (append (reverse 
	     (append
	      (linum&fringe entry (+ 1 linum) linum-column)
	      (type&size&date stat size-column)
	      ;; TODO: readdable?
	      (case (ref stat 'type)
		('regular
		 (entry-regular path dir entry make-url))
		('directory
		 #?=(entry-directory path dir entry make-url))
		('symlink
		 (entry-symlink path dir entry make-url make-symlink-to))
		(else
		 (list "\n"))))
	     )
	    result)))

(define (make-url-default path dir entry type)
  (format "file://~a" (if (eq? type 'symlink)
			  (sys-readlink path)
			  path)))

(define (make-symlink-to-default path)
  (sys-readlink path))

(define css-prefix-default "file:///tmp")

(define (dired path filter make-url make-symlink-to css-prefix)
  (receive (dir entries)
      (if (file-is-directory? path)
	    (values path (directory-list path
					 :add-path? #f 
					 :children? #f
					 :filter (if filter
						     filter
						     (lambda (e) #t))))
	    ;; ???
	    (values (sys-dirname path) (let1 basename (sys-basename path)
					 (if filter
					     (if (filter basename)
						 (list basename)
						 (list))
					     (list basename)))))
    (let* ((stats (map (lambda (entry)
			 (let1 path (build-path dir entry)
			   (list entry path (sys-stat path))))
		       entries))
	   (max-size (fold (lambda (stat current-max)
			     (let1 size (sys-stat->size (caddr stat))
			     (if (< current-max size)
				 size
				 current-max)))
			   0 stats))
	   (max-column (+ (floor->exact (log max-size 10))
			  1)))
      (dired0 dir stats max-column
	      (or make-url make-url-default)
	      (or make-symlink-to make-symlink-to-default)
	      (or css-prefix css-prefix-default)))))
  
(define (dired0 dir entries size-column make-url make-symlink-to css-prefix)
  `(*TOP* 
    (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"") "\n"
    (*DECL* DOCTYPE html PUBLIC 
	    "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd") "\n"
	    (html (|@| (xmlns "http://www.w3.org/1999/xhtml") (xml:lang "en") (lang "en"))
		  "\n"
		  (head 
		   "\n"
		   "	" (title ,dir) "\n"
		   ,@(stylesheets css-prefix))
		  "\n"
		  (body
		   "\n"
		   (pre
		    ,@(reverse (fold-with-index (cute line 
						      dir
						      <>
						      <>
						      (+ (floor->exact (log (length entries) 10)) 1)
						      size-column
						      make-url
						      make-symlink-to
						      <>)
						(list) entries)))
		   "\n"
		   ))))

(provide "yogomacs/dired")

(use yogomacs.dired)
(define (main args)
  (write (dired (cadr args) #f #f #f #f)))
(main '(x "/tmp"))