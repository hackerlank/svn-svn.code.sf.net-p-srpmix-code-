(define-module yogomacs.renderers.yogomacs
  (export yogomacs)
  (use www.cgi)
  (use text.html-lite)
  (use yogomacs.path)
  (use yogomacs.shell)
  (use yogomacs.window)
  )

(select-module yogomacs.renderers.yogomacs)

(define (extra-scripts url params shell)
  `((add-hook find-file-pre-hook (pa$ load-lazy ,url ,params))
    (add-hook toggle-full-screen-hook toggle-full-screen)
    (add-hook read-from-minibuffer-hook ,(ref shell 'interpreter))
    ))

(define (yogomacs path params shell)
  (yogomacs0 path params shell
	     '(("yogomacs--Default.css" . "Default")
	       ("yogomacs--Invert.css" . "Invert"))
	     `(
	       ("biwascheme.js" . file)
	       #;("prototype.js" . file)
	       ("scheme2js_runtime.js" . file)
	       #;("scheme2js_runtime_callcc.js" . file)
	       #;("scheme2js_runtime_interface.js" . file)
	       #;("scheme2js_runtime_interface_callcc.js" . file)
	       ("yogomacs_builtin.js" . file)
	       )))

(define (yogomacs0 path params shell css-list js-list)
  (let* ((shell-name (ref shell 'name))
	 (title (compose-path path))
	 (url title)
	 (next-params #`"yogomacs=,|shell-name|")
	 (next-params (or (and-let* ((range (cgi-get-parameter "range" params
								   :default #f)))
			    (format "range=~a&~a"  (html-escape-string range) next-params))
			  next-params))
	 (js-list (reverse (cons `(,(extra-scripts url next-params shell) . inline)
				 (reverse
				  js-list))))
	 (prompt (ref shell 'prompt))
	 )
    (window title url css-list js-list shell-name prompt)))

(provide "yogomacs/renderers/yogomacs")