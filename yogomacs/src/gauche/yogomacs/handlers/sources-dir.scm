(define-module yogomacs.handlers.sources-dir
  (export sources-dir)
  (use www.cgi)  
  (use file.util)
  (use srfi-1)
  ;;
  (use yogomacs.route)
  ;;
  (use yogomacs.dentry)
  (use yogomacs.dentries.fs)
  (use yogomacs.dired)
  (use yogomacs.path)
  (use yogomacs.handlers.dir)
  ;;
  (use yogomacs.render)
  ;;
  )
(select-module yogomacs.handlers.sources-dir)


(define (dir-handler head path params config)
  (let1 last (last path)
    (prepare-dired-faces config)
    (list
     (cgi-header)
     (render
      (dired (compose-path path)
	     (read-dentries+ (build-path "/srv/sources" head last)
			     (dir-spec (build-path "/" head) last))
	     "/web/css")))))

(define (dir-spec base last)
  `(("." ,(build-path base last))
    (".." ,base)
    (#/.*/ ,(lambda (fs-dentry) 
	      (build-path base 
			  last
			  (dname-of fs-dentry))))))

(define (path->head path)
  (apply build-path (reverse (cdr (reverse path)))))

(define routing-table
  `(
    (#/^\/sources$/ ,(pa$ dir-handler ""))
    (#/^\/sources\/[a-zA-Z0-9]$/ ,(pa$ dir-handler "sources"))
    (#/^\/sources\/[a-zA-Z0-9]\/[^\/]+$/ ,(lambda (path params config)
					   (dir-handler
					    (path->head path)
					    path
					    params
					    config)))))

(define (sources-dir path params config)
  (route routing-table (compose-path path) params config))



(provide "yogomacs/handlers/sources-dir")