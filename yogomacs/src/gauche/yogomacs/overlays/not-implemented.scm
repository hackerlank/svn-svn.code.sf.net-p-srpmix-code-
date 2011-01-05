(define-module yogomacs.overlays.not-implemented
  (use yogomacs.overlay)
  ;;
  (use yogomacs.path)
  (use yogomacs.dests.text)
  (use yogomacs.dentries.text)
  ;;
  (use file.util))

(select-module yogomacs.overlays.not-implemented)

(define-overlay-handler not-implemented
  (lambda (name args)
    (list (car args)
	  (lambda (path params config)
	    (text-dest (make <text-dentry>
			 :parent (compose-path (parent-of path))
			 :dname (car args)
			 :text "NOT IMPLEMENTED YET")
		       path params config)))))

(provide "yogomacs/overlays/not-implemented")