(define-module yogomacs.renderers.find-file
  (export find-file-faces
	  find-file
	  <find-file-error>
	  )
  (use file.util)
  (use font-lock.flclient)
  (use yogomacs.flserver)
  (use yogomacs.caches.css)
  )

(select-module yogomacs.renderers.find-file)

(define find-file-faces
  '(
    default 
    font-lock-comment-delimiter-face
    font-lock-comment-face
    font-lock-constant-face
    font-lock-doc-face
    font-lock-function-name-face
    font-lock-keyword-face
    font-lock-negation-char-face
    font-lock-preprocessor-face
    font-lock-string-face
    font-lock-type-face
    font-lock-variable-name-face
    highlight
    lfringe
    linum
    rfringe
    ))

(define-condition-type <find-file-error> <error> 
  (status)
  )

(define (find-file src-path config)
  (if (readable? src-path)
      (let* ((dest-path (build-path "/tmp" (format "~a.~a" (sys-basename src-path) "shtml")))
	     (shtmlize (pa$ flclient-shtmlize
			    src-path
			    dest-path
			    (css-cache-dir config)
			    :verbose (config 'client-verbose))))
	(flserver shtmlize config)
	(if (file-exists? dest-path)
	    (call-with-input-file dest-path read)
	    (error <find-file-error>
		   :status "504 Gateway Timeout"
		   "Flserver Rendering Timeout")))
      (error <find-file-error>
	     :status "403 Not Found"
	     "File not found")))

(provide "yogomacs/renderers/find-file")