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

(define (extra-scripts)
  `(
    ;;(add-hook find-file-pre-hook (pa$ load-lazy ,url ,next-params))
    ))

(define (yogomacs path params shell)
  (yogomacs0 path shell
	     `((,#`"yogomacs-,(version)-,(release)--Default.css" . "Default")
	       ;;(,#`"yogomacs-,(version)-,(release)--Invert.css" . "Invert")
	       )
	     `(
	       (,#`"yogomacs-,(version)-,(release).js" . file)
	       )))

(define (yogomacs0 url shell css-list js-list)
  (let* ((shell-name (ref shell 'name))
	 (title url)
	 (js-list (reverse (cons `(,(extra-scripts) . inline)
				 (reverse
				  js-list))))
	 (prompt (ref shell 'prompt))
	 )
    (window title url css-list js-list shell-name prompt)))

(provide "yogomacs/renderers/yogomacs")