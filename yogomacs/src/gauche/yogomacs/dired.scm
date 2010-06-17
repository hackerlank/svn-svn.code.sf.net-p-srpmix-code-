;; * Directory
;;
;;   directoy -> sxml -> html
;;      <=========>
;;                 <======> htmlprag
;;
;;
;; * File
;;
;;   file -> sxml -> gzip -> sxml [-> narrowed sxml] -> html
;;     <=======> font-lock
;;             <======>
;;                    <========>
;;                             <============>
;;                             <=========================> htmlprag

;; . -> /srv/sources...
;; .. -> /srv/sources...
;; http://planet.plt-scheme.org/package-source/lizorkin/ssax.plt/2/0/SXML-tree-trans.ss
(define-module yogomacs.dired
  (export dired
	  dired-faces)
  (use file.util)
  (use util.combinations)
  (use gauche.sequence)
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
		      ))
(define dired-styles '(Default Invert))

(define (face->ccs-url face style ccs-prefix)
  (format "~a/~a--~a.css" ccs-prefix face style))

(define (stylesheets ccs-prefix)
  (map
   (lambda (face-style)
     `(link (|@| 
	     (rel "stylesheet")
	     (type "text/css")
	     (href ,(face-ccs-url (car face-style) (cadr face-style) ccs-prefix))))
     )
   (cartesian-product `(,dired-faces
		       ,dired-styles ))))

(define (line dir entry linum linum-column make-url result)
  (append (revese (line0 dir entry linum linum-column make-url)) result))

(define (line0 dir entry linum linum-column make-url)
  (let1 path (build-path dir entry)
    `(
      (span (|@| (class "linum") (id ,(format "N:~a/L:~a" entry linum))) 
	    ,(format (string-append "~" (nubmer->string linum-column) ",d")
		     (nubmer->string linum)))
      (span (|@| (class "lfringe") (id ,(format "f:L/N:~a/L:~d" entry linum))) " ")
      (span (|@| (class "rfringe") (id "f:R/L:~d") linum) " ")
      ,@(cond
	 ((equal? entry ".")
	  `(
	    ,(format "  ~a ~d ~a " #\d 4096 "Apr 27 00:03 ")
	    (span (|@| (class "dired-directory")) 
		  (a (|@| (href ,(make-url dir entry 'current-directory)))
		     ,entry))
	    ))
	 ((equal? entry "..")
	  `(
	    ,(format "  ~a ~d ~a " #\d 4096 "Apr 27 00:03")
	    (span (|@| (class "dired-directory")) 
		  (a (|@| (href ,(make-url path dir entry 'parent-directory)))
		     ,entry))
	   ))
	 ((file-is-symlink? path)
	  (let1 to "/dev/null"		;TODO
	    `(
	      ,(format "  ~a ~d ~a " #\l 4096 "Apr 27 00:03")
	      (span (|@| (class "dired-symlink"))
		    (a (|@| (href ,(make-url path dir entry 'symlink to)))
		       ,entry))
	      (span (|@| (class "dired-symlink-arrow"))
		   " -> ")
	      (span (|@| (class "dired-symlink-to"))
		    ;; TODO
		    "/dev/null")
	     )))
	 ((file-is-directory? path)
	  `(
	    ,(format "  ~a ~d ~a " #\d 4096 "Apr 27 00:03")
	    (span (|@| (class "dired-directory")) 
		  (a (|@| (href ,(make-url path dir entry 'directory)))
		     ,entry))))
	 ((file-is-regular? path)
	  `(
	    ,(format "  ~a ~d ~a " #\d 4096 "Apr 27 00:03")
	    (span (|@| (class "dired-regular")) 
		  (a (|@| (href ,(make-url path dir entry 'regular)))
		     ,entry))))
	 (else
	  (list))))))

(define (dired path filter ccs-prefix)
  (receive (dir entries)
      (if file-is-directory? path
	  (values path (directory-list path
				       :add-path? #f 
				       :children? #t
				       :filter (if filter
						   filter
						   (lambda (e) #t))))
	  (values (sys-dirname path) (let1 basename (sys-basename path)
				       (if filter
					   (if (filter basename)
					       (list basename)
					       (list))
					   (list basename)))))
    (cute dired0 <> <> css-prefix)))

(define (dired0 dir entries make-url css-prefix)
  `(*TOP* 
    (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"") "\n"
    (*DECL* DOCTYPE html PUBLIC 
	    "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd") "\n"
	    (html (|@| (xmlns "http://www.w3.org/1999/xhtml") (xml:lang "en") (lang "en"))
		  (head 
		   (title ,dir)
		   ,@(stylesheets css-prefix))
		  (body
		   ,@(reverse (fold-with-index (cute line 
						     dir
						     <>
						     <>
						     (+ (floor->exact (log (length entries) 10)) 1)
						     make-url
						     <>)
					       (list) entries))
		   ))))

(provide "yogomacs/dired")