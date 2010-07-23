(define-module yogomacs.renderers.fundamental
  (export fundamental)
  (use yogomacs.renderers.text)
  (use yogomacs.access)
  (use yogomacs.error))

(select-module yogomacs.renderers.fundamental)

(define (fundamental src-path fundamental-mode-threshold config)
  (if (readable? src-path)
      (let ((t (ref (sys-stat src-path) 'mtime))
	    (data (call-with-input-file src-path
		    port->string-list
		    :if-does-not-exist :error
		    :element-type :character)))
	(if (and (number? fundamental-mode-threshold)
		 (< fundamental-mode-threshold (length data)))
	    (lines src-path config data t)
	    (values #f t)))
      (not-found "File not found" src-path)))

(provide "yogomacs/renderers/fundamental")