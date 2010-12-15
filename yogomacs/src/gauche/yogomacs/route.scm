(define-module yogomacs.route
  (export route)
  ;(use yogomacs.dests.debug)
  (use yogomacs.error)
  (use yogomacs.sanitize)
  (use yogomacs.path)

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
  (if (null? rtable)
      (not-found #`"Cannot find ,|path| (,(if (post?) \"POST\" \"GET\"))")
      (let* ((regex (car (car rtable)))
	     (actions (cdr (car rtable)))
	     (get-action (if (null? actions) #f (car actions)))
	     (post-action (cond
			   ((null? actions) #f)
			   ((null? (cdr actions)) #f)
			   (else (cadr actions))))
	     (action (if (post?)
			 post-action
			 get-action)))
	(if (regex path)
	    (if action
		(action (decompose-path path) params config)
		(not-found #`"Cannot find POST handler for ,|path|")
		)
	    (route0 (cdr rtable) path params config)))))

;  (when (equal? (cgi-get-metavariable "REQUEST_METHOD") "POST")
;    #?=(read-from-string (uri-decode-string (cgi-get-parameter "stitch" params) :cgi-decode #t)))

(provide "yogomacs/route")