(define-module yogomacs.renderers.find-file
  (export find-file-faces
	  find-file)
  (use file.util)
  (use font-lock.flclient)
  (use yogomacs.flserver)
  (use yogomacs.caches.css)
  (use yogomacs.renderer)
  (use yogomacs.access)
  )

(select-module yogomacs.renderers.find-file)

(define find-file-faces
  '(
    default 
    font-lock-built-in-faces
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
    ;;
    rpm-spec-dir
    rpm-spec-doc
    rpm-spec-ghost
    rpm-spec-macro
    rpm-spec-package
    rpm-spec-section
    rpm-spec-tag
    rpm-spec-var
    ))

(define (find-file src-path config)
   (if (readable? src-path)
       (let* ((dest-path (build-path "/tmp" (format "~a--~a.~a" 
						    (sys-basename src-path)
						    (sys-getpid)
						    "shtml")))
	      (shtmlize (pa$ flclient-shtmlize
			     src-path
			     dest-path
			     (css-cache-dir config)
			     :verbose (config 'client-verbose))))
	  ;;
	  (flserver shtmlize config)
	  ;;
	  (if (file-exists? dest-path)
	      (unwind-protect
		 (call-with-input-file dest-path read)
		 (sys-unlink  dest-path))
	      (timeout "Rendering Timeout"
		 (format "~s -> ~s" src-path dest-path))))
       (not-found "File not found"
		  src-path)))	 

(provide "yogomacs/renderers/find-file")