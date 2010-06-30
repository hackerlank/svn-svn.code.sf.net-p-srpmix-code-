(define-module yogomacs.handlers.pkg-dir
  (export pkg-dir-handler)
  ;;
  (use yogomacs.route)
  (use yogomacs.dentry)

  (use yogomacs.path)
  (use yogomacs.handlers.dir)

  (use yogomacs.handlers.srpmix-dir)
  (use srfi-1)
  (use file.util)
  )
(select-module yogomacs.handlers.pkg-dir)

(define (lcopy-spec path)
  (let ((last (last path))
	(head (path->head path)))
    `((,#/\^lcopy-[^\/]+/ 
		  #t
		  ,(lambda (fs-dentry)
		     (build-path "/" 
				 head
				 last
				 (dname-of fs-dentry)))
		  ;;
		  ,(lambda (fs-dentry)
		     (format "~a,~a" last ((#/\^lcopy-([^\/]+)/ (dname-of fs-dentry)) 1))
		     )))))

(define (handler path params config)
  (dir-handler path params config
	       `(
		 ,@(lcopy-spec path)
		 )))

(define routing-table
  `((#/^\/sources\/[a-zA-Z0-9]\/[^\/]+$/ ,handler)
    ;; (#/^\/sources\/[a-zA-Z0-9]\/\^lcopy-([^\/]+)(?:\/.+)?$/ ,lcopy-dir-handler)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)(?:\/.+)?$/ ,srpmix-dir-handler)
    ))

(define (pkg-dir-handler path params config)
  (route routing-table (compose-path path) params config))


(provide "yogomacs/handlers/pkg-dir")