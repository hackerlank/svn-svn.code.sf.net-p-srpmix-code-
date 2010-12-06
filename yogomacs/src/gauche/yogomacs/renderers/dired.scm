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
  (use yogomacs.entry)
  (use yogomacs.face)
  (use gauche.version)
  (use yogomacs.renderers.ewoc)
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
    ;; TODO
    ;; dired-nlink
    ))
  
(define-constant dired-faces 
  `(
    ,@font-lock-built-in-faces
    ,@dired-native-faces
    ,@dired-foreign-faces
    ))

(define dired-styles '(Default Invert))

;;
;;
;;
(define (url&dname dentry)
  (let1 url (url-of dentry)
    (if url
	`(a (|@| (href ,url))
	    ,(dname-of dentry))
	(dname-of dentry))))
(define (generic-entry dentry)
  `(
    (span (|@| (class ,(case (type-marker-of dentry)
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

(define (arrowy-entry dentry)
  (let ((arrowy-from-shtml (url&dname dentry))
	(arrowy-to-dname (arrowy-to-dname-of dentry)))
    (cond
     (arrowy-to-dname
      `(
	  (span (|@| (class "dired-symlink"))
		,arrowy-from-shtml)
	  ;;
	  " "
	  (span (|@| (class "dired-symlink-arrow"))
		"->")
	  " "
	  (span (|@| (class "dired-symlink-to"))
		,(let1 url (arrowy-to-url-of dentry)
		   (if url
		       `(a (|@| (href ,url))
			   ,arrowy-to-dname)
		       arrowy-to-dname)))
	  "\n"))
     (arrowy-from-shtml
      `(,arrowy-from-shtml "\n"))
     (else
      `(
	(span (|@| (class "dired-broken-symlink"))
	      ,(dname-of dentry))
	"\n")))))

(define (executable-entry dentry)
  `(
    (span (|@| (class "dired-executable"))
	  ,(url&dname dentry))
    "\n"))

(define (nlink&size&date dentry nlink-column size-column)
  `(
    " "
    (span (|@| (class "dired-nlink"))
	  ,(format #`"~,(number->string nlink-column),,d"
		   (nlink-of dentry)))
    " "
    (span (|@| (class "dired-size"))
	  ,(format #`"~,(number->string size-column),,d"
		   (size-of dentry)))
    " "
    (span (|@| (class "dired-date"))
	  ,(date->string (time-utc->date (mtime-of dentry))
			 "~b ~e ~H:~M ~Y"
			 )
	  )
    " "
    ))

;;
;;
;;


(define css-prefix-default "file:///tmp")

(define-class <dired> (<ewoc>)
  ((dir :init-keyword :dir)
   (size-column)
   (nlink-column)
   ))

(define-class <dired-header-entry> (<entry>)
  ((dir :init-keyword :dir)))

(define (dired dir dentries css-prefix)
  (render-entries 
   (make <dired> :dir dir)
   (sort dentries
	 (lambda (a b)
	   (let ((a-name (dname-of a))
		 (b-name (dname-of b)))
	     (guard (e (else (string<? a-name b-name)))
	       (string<? a-name b-name)))))
   (or css-prefix css-prefix-default)))

(define-method title-of ((dired <dired>))
  (ref dired 'dir))

(define-method meta-tags-of ((dired <dired>))
  `(("major-mode" . "dired-mode")
    ("created-time" . ,(date->string (time-utc->date (current-time)) "~5"))
    ("version" . ,(format "~d.~d.~d"
			  dired-major-version
			  dired-minor-version
			  dired-micro-version))
    ))

(define-method faces-and-styles-of ((dired <dired>))
  (cartesian-product `(,dired-faces
		       ,dired-styles )))

(define-method href-id-of ((dired <dired>)
			   (dentry <dentry>)
			   (index <integer>))
  #`"N:,(dname-of dentry)"
  )

(define-method render-entry ((dired <dired>)
			     (dentry <dentry>))
  `(
    (span (|@| (class "dired-entry-type"))
	  ,(x->string (type-marker-of dentry)))
    ,(x->string (input-marker-of dentry))
    ,(x->string (output-marker-of dentry))
    ,(x->string (delete-marker-of dentry))
    ,(x->string (command-marker-of dentry))
    " "
    ,@(nlink&size&date dentry (ref dired 'nlink-column) (ref dired 'size-column))
    ,@(cond
       ((arrowy? dentry) (arrowy-entry dentry))
       (else (generic-entry dentry)))))

(define-method render-entry ((dired <dired>)
			     (hentry <dired-header-entry>))
  `(
    ;; TODO Make this to hyper link
    (span (|@| (class "dired-header"))
	  ,(ref hentry 'dir))
    ":\n"
    )
  )

(define-method href-id-of ((ewoc <dired>) 
			   (hentry <dired-header-entry>)
			   (index <integer>))
  "/header"
  )


(define-method render-entries ((dired <dired>)
			       (dentries <list>)
			       (css-prefix <string>))
  (let ((max-size (fold (lambda (dentry current-max-size)
			  (let1 size (size-of dentry)
			    (if (< current-max-size size)
				size
				current-max-size)))
			0
			dentries))
	(max-links (fold (lambda (dentry current-max-links)
			   (let1 nlink (nlink-of dentry)
			     (if (< current-max-links nlink)
				 nlink
				 current-max-links)))
			0
			dentries)))
    (set! (ref dired 'nlink-column)
	  (+ (floor->exact (log (max max-links 1) 10))
	     1))
    (set! (ref dired 'size-column)
	  (+ (floor->exact (log (max max-size 1) 10))
	     1))
    (next-method dired 
		 (cons (make <dired-header-entry> :dir (ref dired 'dir))
		       dentries)
		 css-prefix)))

(provide "yogomacs/renderers/dired")
