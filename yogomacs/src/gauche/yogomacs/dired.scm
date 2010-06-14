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
(define-module yogomacs.dired
  (export dired)
  )
(select-module yogomacs.dired)

(define (dired dir)
  `(*TOP* (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"")
	  "\n"
	  (*DECL* DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd")
	  "\n"
	  (html (|@| 
		 (xmlns "http://www.w3.org/1999/xhtml")
		 (xml:lang "en")
		 (lang "en")
		 )
		(head 
		 (title "/sources/e/emacs/23.2-3.fc14/pre-build/emacs-23.2")
		 (link (|@| (rel "stylesheet") (type "text/css") (href "http://srpmix.org/api/css/default.css"))) "\n"
		 (link (|@| (rel "stylesheet") (type "text/css") (href "http://srpmix.org/api/css/highlight.css"))) "\n"
		 (link (|@| (rel "stylesheet") (type "text/css") (href "http://srpmix.org/api/css/linum.css"))) "\n"
		 (link (|@| (rel "stylesheet") (type "text/css") (href "http://srpmix.org/api/css/fringe.css"))) "\n"
		 (link (|@| (rel "stylesheet") (type "text/css") (href "http://srpmix.org/api/css/dired-header.css"))) "\n"
		 (link (|@| (rel "stylesheet") (type "text/css") (href "http://srpmix.org/api/css/dired-directory.css"))) "\n"
		 (link (|@| (rel "stylesheet") (type "text/css") (href "http://srpmix.org/api/css/dired-marked.css"))) "\n"
		 (link (|@| (rel "stylesheet") (type "text/css") (href "http://srpmix.org/api/css/dired-symlink.css"))) "\n"
		 (link (|@| (rel "stylesheet") (type "text/css") (href "http://srpmix.org/api/css/dired-perm-write.css"))) "\n"
		 ) 
		(body 
		 (script (|@| (src "http://srpmix.org/api/js/biwascheme.js")) "\n" 
			 "(load \"http://srpmix.org/api/scm/yogomacs.scm\")\n") "\n" 
			 (pre 
			  (span (|@| (class "linum") (id "linum:1")) "1")
			  (span (|@| (class "fringe") (id "name:.srpmix_dired_header")) " ")
			  (span (|@| (class "dired-header")) "  /sources/e/emacs/23.2-3.fc14/pre-build/emacs-23.2") ":\n"
			  (span (|@| (class "linum") (id "linum:2")) "2")
			  (span (|@| (class "fringe") (id "name:.srpmix_dired_total_line")) " ")
			  "  total used in directory 33 available 1152921504606846976\n"
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
			  "\n") (div (|@| (class "default") (id "bs-console"))) "\n")))
  )

(provide "yogomacs/dired")