(define-module yogomacs.renderers.fundamental
  (export fundamental)
  (use yogomacs.renderers.text)
  (use yogomacs.access)
  (use yogomacs.error))

(select-module yogomacs.renderers.fundamental)

(define (try-input-file->string-list path original-encodings . rest)
  (let loop ((encodings original-encodings)
	     (result #f))
    (cond
     (result result)
     ((null? encodings)
      (errorf <read-error> "Failed in code conversion: ~a" original-encodings))
     (else
      (guard (e ((<read-error> e) (loop (cdr encodings) result)))
	(loop (cdr encodings)
	      (apply call-with-input-file path
		     port->string-list
		     (if (car encodings)
			 (cons :encoding (cons (car encodings) rest))
			 rest))))))))

(define encodings '(#f "LATIN1"))

(define (fundamental src-path
		     fundamental-mode-line-threshold
		     fundamental-mode-column-threshold
		     config)
  (if (readable? src-path)
      (let* ((t (ref (sys-stat src-path) 'mtime))
	     (data (try-input-file->string-list src-path
						encodings
						:if-does-not-exist :error
						:element-type :character
						))
	     (data (if (null? data) '("") data))
	    )
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