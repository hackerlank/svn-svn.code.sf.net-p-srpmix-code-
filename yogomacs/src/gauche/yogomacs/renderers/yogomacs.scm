(define-module yogomacs.renderers.yogomacs
  (export yogomacs)
  (use www.cgi)
  (use text.html-lite)
  (use util.list)
  (use yogomacs.path)
  (use yogomacs.dests.js)
  (use yogomacs.scheme2js)
  (use yogomacs.shell)
  )

(select-module yogomacs.renderers.yogomacs)


(define (make-updater url params)
  (scm->js
   `(let ((options (js-new Object)))
      (set! options.method "get")
      (set! options.parameters ,params)
      (set! options.onFailure (lambda ()
				(alert "An error occured")))
      (js-new Ajax.Updater
	      "buffer"
	      ,url
	      options))))
   
(define (make-url-list url shell-name)
  (let1 splited-list (let loop ((url url)
				(result (list)))
		       (if (equal? "/" url)
			   result
			   (loop  (sys-dirname url)
				  (cons url result))))
    (cons `(a (|@| (href ,#`"/,|shell-name|/")) "/")
	  (intersperse "/"
		       (map
			(lambda (elt)
			  `(a (|@| (href ,#`"/,|shell-name|,|elt|")) ,(sys-basename elt)))
			splited-list)))))



(define (yogomacs path params shell)
  (let* ((shell-name (ref shell 'name))
	 (title (compose-path path))
	 (url title)
	 (yogomacs-params #`"yogomacs=,|shell-name|")
	 (yogomacs-params (or (and-let* ((range (cgi-get-parameter "range" params
								   :default #f)))
				(format "range=~a&~a"  (html-escape-string range) yogomacs-params))
			      yogomacs-params))
	 (script (make-updater url yogomacs-params))
	 (url-list (make-url-list url shell-name)))

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
		   "\n" 
		   "    " (title ,title)
		   "\n" "    "
		   (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/yogomacs--Default.css") (title "Default")))
		   "\n" "    "
		   (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/yogomacs--Invert.css") (title "Invert")))
		   "\n" "    "
		   ) 
		  "\n" "    "
		  (body 
		   "\n" "    "
		   (pre (|@| (class "header-line") (id "header-line")))
		   (pre (|@| (class "header-line-control") (id "header-line-control")) "|-")
		   "\n"
		   "\n"
		   (pre (|@| (class "buffer") (id "buffer")) ,#`"Loading...,|url|\n")
		   "\n"
		   ;;
		   ;;
		   ;;
		   (pre (|@| (class "modeline") (id "modeline"))  ,@url-list)
		   (pre (|@| (class "modeline-control") (id "modeline-control"))  "|-")
		   "\n"
		   ;;
		   ;;
		   ;;
		   (form (|@| (class "minibuffer-shell")) (input (|@| (type "text") (id "minibuffer") (class "minibuffer"))))
		   (pre (|@| (class "minibuffer-prompt-shell")) (span (|@| (id "minibuffer-prompt") (class "minibuffer-prompt")) 
								      ,(ref shell 'prompt)))
		   "\n" "  "
		   ;;
		   ;;
		   ;;
		   (script (|@| (type "text/javascript") (src ,(js-route$ "prototype.js"))) " ")
		   "\n" "  "
		   (script (|@| (type "text/javascript") )
			   (*COMMENT* ,script))
		   "\n" "    "
		   ) 
		  "\n" "  "
		  "\n")
	    "\n")))

(provide "yogomacs/renderers/yogomacs")