(define-module yogomacs.renderers.yogomacs
  (export yogomacs)
  (use text.html-lite)
  (use srfi-1)
  (use util.list)
  (use yogomacs.path)
  (use yogomacs.shell)
  (use yogomacs.window)
  (use yogomacs.config)
  )

(select-module yogomacs.renderers.yogomacs)

(define (extra-scripts url current-params next-params shell)
  `((add-hook find-file-pre-hook (pa$ load-lazy ,url ,next-params))
    (add-hook find-file-pre-hook ,(ref shell 'initializer))
    (add-hook toggle-full-screen-hook toggle-full-screen)
    (add-hook read-from-minibuffer-hook ,(ref shell 'interpreter))
    ))

(define (yogomacs path params shell)
  (yogomacs0 path params shell
	     '(("yogomacs--Default.css" . "Default")
	       ;("yogomacs--Invert.css" . "Invert")
	       )
	     `(
	       (,#`"yogomacs-,(version)-,(release).js" . file)
	       )))

(define (yogomacs0 path params shell css-list js-list)
  (let* ((shell-name (ref shell 'name))
	 (title (compose-path path))
	 (url title)
	 (next-params #`"yogomacs=,|shell-name|")
	 (next-params (or (and-let* ((range (params "range")))
			    (format "range=~a&~a"  (html-escape-string range) next-params))
			  next-params))
	 (next-params (or (and-let* ((enum (params "enum")))
			    (format "enum=~a&~a"  (html-escape-string enum) next-params))
			  next-params))
	 (js-list (reverse (cons `(,(extra-scripts url params next-params shell) . inline)
				 (reverse
				  js-list))))
	 (prompt (ref shell 'prompt))
	 )
    (window title url css-list js-list shell-name prompt)))

(provide "yogomacs/renderers/yogomacs")