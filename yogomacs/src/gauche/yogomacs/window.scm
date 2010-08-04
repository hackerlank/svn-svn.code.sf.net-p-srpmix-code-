(define-module yogomacs.window
  (export window)
  (use yogomacs.dests.js)		;wrong?
  (use yogomacs.dests.css)		;wrong?
  (use yogomacs.scheme2js)
  (use yogomacs.shell)
  (use yogomacs.shells.ysh)
  (use yogomacs.shells.bscm)
  (use util.list)
  (use srfi-1))
(select-module yogomacs.window)

;; css-list: ((css-file . title)...)
(define (expand-css-list css-list)
  (fold-right (lambda (elt result)
		(cons* `(link (|@| 
			       (rel "stylesheet") 
			       (type "text/css")
			       (href ,(css-route$ (car elt)))
			       (title ,(cdr elt))))
		       "\n"
		       "    "
		       result))
	      (list)
	      css-list))

;; js-list:  ((js-file . file)  (js-exps . inlin)...)
(define (expand-js-list js-list)
  (fold-right (lambda (js result)
		(cons*
		 (case (cdr js)
		   ('file
		    `(script (|@|
			      (type "text/javascript") 
			      (src ,(js-route$ (car js)))) " "))
		   ('defer
		     `(*COMMENT* ,(js-route$ (car js)))
		     )
		   (else
		    `(script (|@| (type "text/javascript") )
			     (*COMMENT*
			      ,(string-append "\n"
					      (scm->js (car js))
					      "// "
					      )))))
		 "\n"
		 "    "
		 result))
	      (list)
	      js-list))


(define (expand-deferred-js-list js-list)
  (fold-right (lambda (js result)
		(if (eq? (cdr js) 'defer)
		    (cons*
		     `(script  (|@|
				(type "text/javascript") 
				(defer "defer")
				(src ,(js-route$ (car js)))) " ")
		     "\n"
		     "    "
		     result)
		    result))
	      (list)
	      js-list))


(define (make-url-list url shell)
  (let1 splited-list (let loop ((url url)
				(result (list)))
		       (if (equal? "/" url)
			   result
			   (loop  (sys-dirname url)
				  (cons url result))))
    (cons `(a (|@| (href ,#`"/,|shell|/")) "/")
	  (intersperse "/"
		       (map
			(lambda (elt)
			  `(a (|@| (href ,#`"/,|shell|,|elt|")) 
			      ,(sys-basename elt)))
			splited-list)))))

;; (define (expand-shell-list shell prompt)
;;   (map 
;;    (lambda (s)
;;      (if (and (equal? shell (ref s 'name))
;; 	      (equal? prompt (ref s 'prompt)))
;; 	 `(option (|@| (selected "selected")) ,prompt)
;; 	 `(option ,(ref s 'prompt))))
;;    (all-shells)))

(define (window title url css-list js-list shell prompt)
  `(*TOP* (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"") "\n" 
	  (*DECL* DOCTYPE 
		  html
		  PUBLIC
		  "-//W3C//DTD XHTML 1.0 Transitional//EN"
		  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		  ) 
	  "\n"
	  (html (|@| (xmlns "http://www.w3.org/1999/xhtml") (xml:lang "en") (lang "en"))
		"\n"
		(head 
		 "\n" "    "
		 (title ,title)
		 "\n" "    "
		 ,@(expand-css-list css-list)
		 ,@(expand-js-list js-list)
		 ) 
		"\n" "    "
		(body (|@| (onload "run_find_file_pre_hook();"))
		      "\n" "    "
		      (pre (|@| (class "header-line") (id "header-line")) " ")
		      (pre (|@| 
			       (class "header-line-control")
			       (id "header-line-control")
			       (onclick "run_toggle_full_screen_hook();")
			       ) (a (|@| (href "#"))  ">>>")) "\n"
		      ;;
		      (pre (|@| (class "buffer") (id "buffer")) ,#`"Loading...,|url|\n") "\n"
		      ;;
		      (pre (|@| (class "modeline") (id "modeline"))  ,@(make-url-list url shell))
		      (pre (|@| 
			    (class "modeline-control") 
			    (id "modeline-control")
			    ) 
			   (a (|@| (href ,#`"file:///srv/sources,|url|")) "@")
			   )
		      "\n"
		      ;;
		      (form (|@| 
			     (id "minibuffer-shell")
			     (class "minibuffer-shell")
			     (onsubmit "return false;") )
			    (input (|@|
				    (type "text") 
				    (id "minibuffer")
				    (class "minibuffer")
				    (onchange "run_read_from_minibuffer_hook();")
				    )))
		      (pre (|@| 
			    (id "minibuffer-prompt-shell")
			    (class "minibuffer-prompt-shell"))
			   (span (|@| 
				  (id "minibuffer-prompt")
				  (class "minibuffer-prompt")) 
				 ,prompt))
		      #;(form (|@| 
			     (id "minibuffer-prompt-shell")
			     (class "minibuffer-prompt-shell")) 
			    (select (|@| 
				     (type "select") 
				     (id "minibuffer-prompt")
				     (size "1")
				     (class "minibuffer-prompt")
				     
				     )
				    ,@(expand-shell-list shell prompt)))
		      "\n" "    "
		      ,@(expand-deferred-js-list js-list)
		      ) 
		"\n" "  "
		"\n")
	  "\n"))

(provide "yogomacs/window")
