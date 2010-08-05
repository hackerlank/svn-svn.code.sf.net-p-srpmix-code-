(define-module yogomacs.renderers.fundamental
  (export fundamental)
  (use yogomacs.renderers.text)
  (use yogomacs.access)
  (use yogomacs.error))

(select-module yogomacs.renderers.fundamental)

(define (fundamental src-path
		     fundamental-mode-line-threshold
		     fundamental-mode-column-threshold
		     config)
  (if (readable? src-path)
      (let ((t (ref (sys-stat src-path) 'mtime))
	    (data (call-with-input-file src-path
		    port->string-list
		    :if-does-not-exist :error
		    :element-type :character)))
	(if (or (and (number? fundamental-mode-line-threshold)
		     (<= fundamental-mode-line-threshold 
			 (length data)))
		(and
		 (number? fundamental-mode-column-threshold)
		 (<= fundamental-mode-column-threshold 
		     (apply max (map string-length data)))))
	    (lines src-path config data t)
	    (values #f t)))
      (not-found "File not found" src-path)))

(provide "yogomacs/renderers/fundamental")