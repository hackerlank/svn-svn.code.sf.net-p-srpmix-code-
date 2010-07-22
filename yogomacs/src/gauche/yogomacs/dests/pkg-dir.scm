(define-module yogomacs.dests.pkg-dir
  (export pkg-dir-dest)
  ;;
  (use yogomacs.route)
  (use yogomacs.dentry)

  (use yogomacs.path)
  (use yogomacs.dests.dir)

  (use yogomacs.dests.srpmix-dir)
  (use srfi-1)
  (use file.util)
  )
(select-module yogomacs.dests.pkg-dir)

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
		     )
		  ;; XXX
		  ))))

(define (dest path params config)
  (dir-dest path params config
	       (lcopy-spec path)))

(define routing-table
  `((#/^\/sources\/[a-zA-Z0-9]\/[^\/]+$/ ,dest)
    ;; (#/^\/sources\/[a-zA-Z0-9]\/\^lcopy-([^\/]+)(?:\/.+)?$/ ,lcopy-dir-dest)
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+\/([^^\/]+)(?:\/.+)?$/ ,srpmix-dir-dest)
    ))

(define (pkg-dir-dest path params config)
  (route routing-table (compose-path path) params config))


(provide "yogomacs/dests/pkg-dir")