(define-module yogomacs.overlays.text-file
  (use yogomacs.overlay)
  ;;
  (use yogomacs.path)
  (use yogomacs.dests.text)
  (use yogomacs.dentries.text)
  ;;
  (use file.util))

(select-module yogomacs.overlays.text-file)

(define (text->dest name text)
  (lambda (path params config)
    (text-dest (make <text-dentry>
		 :parent (compose-path (parent-of path))
		 :dname name
		 :text text)
	       path params config)))

(define-overlay-handler text-file
  (lambda (name args)
    (let ((entry-name (car args))
	  (text-file (cadr args)))
      (or (and-let* (( (file-is-regular? text-file) )
		     ( (file-is-readable? text-file) )
		     (iport (open-input-file text-file
					     :if-does-not-exist #f))
		     (text (port->string iport)))
	    (if-let1 dest (text->dest entry-name text)
		     (list entry-name dest)
		     #f))
	  #f))))

(provide "yogomacs/overlays/text-file")