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
(define-module yogomacs.renderers.dired
  (export dired
	  dired-native-faces
	  dired-foreign-faces
	  dired-faces
	  dired-styles)
  (use file.util)
  (use util.combinations)
  (use gauche.sequence)
  (use srfi-1)
  (use srfi-19)
  (use yogomacs.dentry)
  (use yogomacs.face)
  (use gauche.version)
  )
(select-module yogomacs.renderers.dired)

(define-constant dired-major-version 0)
(define-constant dired-minor-version 0)
(define-constant dired-micro-version 0)

(define-constant font-lock-built-in-faces 
  '(
    default
    highlight
    linum
    lfringe
    rfringe
    ))

(define-constant dired-native-faces
  '(
    dired-header
    dired-directory
    dired-symlink
    ))

(define-constant dired-foreign-faces
  '(
    dired-regular	  
    dired-unknown	  
    dired-symlink-arrow 
    dired-broken-symlink		
    dired-symlink-to	
    dired-executable	
    dired-entry-type	
    dired-size	  
    dired-date	  
    ))
  
(define-constant dired-faces 
  `(
    ,@font-lock-built-in-faces
    ,@dired-native-faces
    ,@dired-foreign-faces
    ))

(define dired-styles '(Default Invert))

(define (stylesheets css-prefix)
  (reverse
   (fold
    (lambda (face-style result)
      (cons "\n" (cons `(link (|@| 
			       (rel "stylesheet")
			       (type "text/css")
			       (href ,(face->css-route (car face-style) (cadr face-style) css-prefix))
			       (title ,(x->string (cadr face-style)))
			       )) 
		       (cons "	" result))))
    (list)
    (cartesian-product `(,dired-faces
			 ,dired-styles )))))

(define (url&dname dentry)
  (let1 url (url-of dentry)
    (if url
	`(a (|@| (href ,url))
	    ,(dname-of dentry))
	(dname-of dentry))))
(define (generic-entry dentry)
  `(
    (span (|@| (class ,(case (type-maker-of dentry)
			 ((#\-)
			  "dired-regular")
			 ((#\d)
			  "dired-directory")
			 (else
			  "dired-unknown"))))
	  ;;
	  ,(url&dname dentry)
	  )
    "\n"))

(define (symlink-entry dentry)
  (let1 symlink-to-dname (symlink-to-dname-of dentry)
    (if symlink-to-dname
      	`(
	  (span (|@| (class "dired-symlink"))
		,(url&dname dentry))
	  ;;
	  " "
	  (span (|@| (class "dired-symlink-arrow"))
		"->")
	  " "
	  (span (|@| (class "dired-symlink-to"))
		,(let1 url (symlink-to-url-of dentry)
		   (if url
		       `(a (|@| (href ,url))
			   ,symlink-to-dname)
		       symlink-to-dname)))
	  "\n")
	`(
	  (span (|@| (class "dired-broken-symlink"))
		,(dname-of dentry))
	  "\n"))))

(define (executable-entry dentry)
  `(
    (span (|@| (class "dired-executable"))
	  ,(url&dname dentry))
    "\n"))

(define (linum&fringe dentry linum linum-column)
  (let* ((dname (dname-of dentry))
	 (id (format "N:~a/L:~a" dname linum)))
    `((span (|@| (class "linum") (id ,id))
	    (a (|@| (href ,(format "#~a" id)))
	       ,(format (string-append "~" (number->string linum-column) ",d")
			linum)))
      (span (|@| (class "lfringe") (id ,(format "l/N:~a" dname))) " ")
      (span (|@| (class "rfringe") (id ,(format "r/N:~a" dname))) " "))))

(define (type&size&date dentry size-column)
  `(
    " "
    (span (|@| (class "dired-entry-type"))
	  ,(x->string (type-maker-of dentry)))
    " "
    (span (|@| (class "dired-size"))
	  ,(format (string-append "~" (number->string size-column) ",d")
		   (size-of dentry)))
    "  "
    (span (|@| (class "dired-date"))
	  ,(date->string (time-utc->date (mtime-of dentry))
			 "~b ~e ~H:~M ~Y"
			 )
	  )
    "  "
    ))

(define (line0 dir linum dentry linum-column size-column)
  `(
    ,@(linum&fringe dentry (+ 1 linum) linum-column)
    ,@(type&size&date dentry size-column)
    ,@(cond
       ((symlink? dentry) (symlink-entry dentry))
       ((executable? dentry) (executable-entry dentry))
       (else (generic-entry dentry)))))

(define (line dir linum dentry linum-column size-column result)
  (append (reverse 
	   (line0 dir
		  linum
		  dentry 
		  linum-column
		  size-column))
	  result))

(define css-prefix-default "file:///tmp")
(define (dired dir dentires css-prefix)
  (let* ((max-size (fold (lambda (dentry current-max-size)
			   (let1 size (size-of dentry)
			     (if (< current-max-size size)
				 size
				 current-max-size)))
			 0
			 dentires))
	 (max-column (+ (floor->exact (log (max max-size 1) 10))
			1)))
    (dired0 dir (sort dentires
		      (lambda (a b)
			 (let ((a-name (dname-of a))
			       (b-name (dname-of b)))
			    (guard (e (else (string<? a-name b-name)))
				(string<? a-name b-name)))))
	    (+ (floor->exact (log (length dentires) 10)) 1)
	    max-column
	    (or css-prefix css-prefix-default))
    ))

(define (dired0 dir entries linum-column size-column css-prefix)
  `(*TOP* 
    (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"") "\n"
    (*DECL* DOCTYPE html PUBLIC 
	    "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd") "\n"
	    (html (|@| (xmlns "http://www.w3.org/1999/xhtml") (xml:lang "en") (lang "en"))
		  "\n"
		  (head 
		   "\n"
		   "	" (title ,dir) "\n"
		   ;;
		   ,@(append-map
		      (lambda (elt)
			(list "	"
			      `(meta (|@|
				      (name ,(car elt))
				      (content ,(cdr elt))))
			      "\n"))
		      `(("major-mode" . "dired-mode")
			("created-time" . ,(date->string (time-utc->date (current-time)) "~5"))
			("version" . ,(format "~d.~d.~d"
					      dired-major-version
					      dired-minor-version
					      dired-micro-version))
			))
		   ,@(stylesheets css-prefix))
		  "\n"
		  (body
		   "\n"
		   (pre
		    ,@(reverse (fold-with-index (cute line 
						      dir
						      <>
						      <>
						      linum-column
						      size-column
						      <>)
						(list)
						entries)))
		   "\n"
		   ))))

(provide "yogomacs/renderers/dired")
