(define-module yogomacs.dests.ysh-dir
  (export ysh-dir-dest)
  (use yogomacs.reply)
  (use yogomacs.dests.file)
  (use yogomacs.dests.dir)
  (use yogomacs.dests.js)
  (use yogomacs.path)
  (use util.list)
  (use www.cgi)
  (use text.html-lite)
  )
(select-module yogomacs.dests.ysh-dir)

(define (make-updater target url params)
  #`"
new Ajax.Updater(
    \",|target|\",,
    \",|url|\",,
    {  parameters:\",|params|\",,
       method:\"get\",,
        onFailure : function() {
            alert(\"An error occurred\");
            }
    }
);
// ")

(define (make-url-list url)
  (let1 splited-list (let loop ((url url)
				(result (list)))
		       (if (equal? "/" url)
			   result
			   (loop  (sys-dirname url)
				  (cons url result))))
    (cons '(a (|@| (href "/ysh/")) "/")
	  (intersperse "/"
		       (map
			(lambda (elt)
			  `(a (|@| (href ,#`"/ysh,|elt|")) ,(sys-basename elt)))
			splited-list)))))



(define (template path params)
  (let* ((title (compose-path path))
	 (target "buffer")
	 (url title)
	 (ysh-params "ysh=t")
	 (ysh-params (or (and-let* ((range (cgi-get-parameter "range" params
							      :default #f)))
			   (format "range=~a&~a"  (html-escape-string range) ysh-params))
			 ysh-params))
	 (script (make-updater target url ysh-params))
	 (url-list (make-url-list url)))

    `(*TOP* (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"") "\n" 
	    (*DECL* DOCTYPE 
		    html
		    PUBLIC
		    "-//W3C//DTD XHTML 1.0 Transitional//EN"
		    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		    ) 
	    "\n" 
	    (*COMMENT* " Created by xhtmlize-1.34 in external-css mode. ")
	    "\n"
	    (html (|@| (xmlns "http://www.w3.org/1999/xhtml") (xml:lang "en") (lang "en"))
		  "\n"
		  (head 
		   "\n" 
		   "    " (title ,title)
		   "\n" "    "
		   (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/ysh--Default.css") (title "Default")))
		   "\n" "    "
		   (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/ysh--Invert.css") (title "Invert")))
		   "\n" "    "
		   ) 
		  "\n" "    "
		  (body 
		   "\n" "    "
		   (div (pre (|@| (class "header-line") (id "header-line"))))
		   "\n"
		   (pre (|@| (class "buffer") (id "buffer")) "\n")
		   "\n"
		   (pre (|@| (class "modeline") (id "modeline"))  ,@url-list)
		   "\n"
		   (form (|@| (class "minibuffer-shell")) (input (|@| (type "text") (id "minibuffer") (class "minibuffer"))))
		   "\n"
		   (pre (|@| (class "minibuffer-prompt-shell")) (span (|@| (id "minibuffer-prompt") (class "minibuffer-prompt")) 
								      " <ysh"))
		   "\n" "  "
		   (script (|@| (type "text/javascript") (src ,(js-route$ "prototype.js"))) " ")
		   "\n" "  "
		   (script (|@| (type "text/javascript") )
			   (*COMMENT* ,script))
		   "\n" "    "
		   ) 
		  "\n" "  "
		  "\n")
	    "\n")))

(define (ysh-dir-dest path params config)
  (let1 shtml (template (cdr path) params)
    (make <shtml-data>
      :params params
      :config config
      ;; title
      ;; lazy-loading
      :data ((compose fix-css-href
		      integrate-file-face
		      integrate-dired-face) shtml)
      :last-modification-time #f)))

(provide "yogomacs/dests/ysh-dir")