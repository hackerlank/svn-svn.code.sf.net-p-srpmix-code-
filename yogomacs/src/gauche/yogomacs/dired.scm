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
  )
(select-module yogomacs.dired)

(define template `(*TOP* 
		   (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"") "\n"		 
		   (*DECL* DOCTYPE html PUBLIC 
			   "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd")
		   (html (|@| 
			  (xmlns "http://www.w3.org/1999/xhtml")
			  (xml:lang "en")
			  (lang "en")
			  )
			 (head 
			  (title)
			  (stylesheets)
			  )
			 (body))))
(define dired-faces '(
		      default
		      highlight
		      linum
		      lfringe
		      rfringe
		      dired-header
		      dired-directory
		      dired-symlink
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

(define (entry name line)
  `(
    (span (|@| (class "linum") (id ,(format "L:~d" line)))
	  (a (href "#N:~a" name) (format "~d" line))
	  )
    
    
  
  
(define (body dir)
  (pre 
   (span (|@| (class "linum") (id "linum:3")) "3")
   (span (|@| (class "fringe") (id "name:.")) " ")
   "  drms n sources srpmix 4096  1983-09-27 12:35 "
   (a (|@| (href "http://srpmix.org/api/browse.cgi?path=sources/e/emacs/23.2-3.fc14/pre-build/emacs-23.2&amp;display=font-lock")) (span (|@| (class "dired-directory")) "."))
   "\n"
   (span (|@| (class "linum") (id "linum:4")) "4")
   (span (|@| (class "fringe") (id "name:..")) " ")
   "  drms n sources srpmix 4096  1983-09-27 12:35 "
   (a (|@| (href "http://srpmix.org/api/browse.cgi?path=sources/e/emacs/23.2-3.fc14/pre-build&amp;display=font-lock")) (span (|@| (class "dired-directory")) ".."))
   "\n"
   (span (|@| (class "linum") (id "linum:5")) "5")
   (span (|@| (class "fringe") (id "name:ChangeLog")) " ")
   "  -rms n sources srpmix 4096  1983-09-27 12:35 "
   (a (|@| (href "http://srpmix.org/api/browse.cgi?path=sources/e/emacs/23.2-3.fc14/pre-build/emacs-23.2/ChangeLog&amp;display=font-lock")) "ChangeLog")
   "\n"
   (span (|@| (class "linum") (id "linum:6")) "6")
   (span (|@| (class "fringe") (id "name:lisp")) " ")
   "  drms n sources srpmix 4096  1983-09-27 12:35 "
   (a (|@| (href "http://srpmix.org/api/browse.cgi?path=sources/e/emacs/23.2-3.fc14/pre-build/emacs-23.2/lisp&amp;display=font-lock")) (span (|@| (class "dired-directory")) "lisp"))
   "\n")
  )

(define (dired dir ccs-prefix)
  )

(provide "yogomacs/dired")