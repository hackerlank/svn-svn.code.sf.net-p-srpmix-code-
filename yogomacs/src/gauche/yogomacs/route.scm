(define-module yogomacs.route
  (export route)
  ;(use yogomacs.dests.debug)
  (use yogomacs.error)
  (use yogomacs.sanitize)
  (use yogomacs.path)
  ;;
  (use www.cgi)
  )
(select-module yogomacs.route)

(define (post?)
  (equal? 
   (cgi-get-metavariable "REQUEST_METHOD")
   "POST"))

(define (route rtable path params config)
  (route0 rtable
	  ;; TODO check ((sanitize-path path) == path) => redirect
	  (sanitize-path path)
	  params
	  config))

(define (route0 rtable path params config)
  (let1 method (if (post?) "POST" "GET")
    (if (null? rtable)
	(not-found #`"Cannot find ,|path|" path)
	(let1 regex (car (car rtable))
	  (if (or (and (string? regex) (equal? regex path))
		  (and (regexp? regex) (regex path)))
	      (let* ((actions (cdr (car rtable)))
		     (get-action (if (null? actions) #f (car actions)))
		     (post-action (cond
				   ((null? actions) #f)
				   ((null? (cdr actions)) #f)
				   (else (cadr actions))))
		     (action (if (post?)
				 post-action
				 get-action)))
		(if action
		    (action (decompose-path path) params config)
		    (method-not-allowed 
		     #`"Cannot find ,|method| handler for ,|path|"
		     path)))
	      (route0 (cdr rtable) path params config))))))

(provide "yogomacs/route")