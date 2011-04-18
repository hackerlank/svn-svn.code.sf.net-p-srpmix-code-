(define major-mode #f)
(define has-tag? #f)

(define (setup-major-mode . any)
  (define (read-meta name)
    (let* ((elt ($ name))
	   (data (read-from-string elt.innerHTML)))
      (elt.remove)
      data))
  (set! major-mode (read-meta "major-mode"))
  (set! has-tag? (read-meta "has-tag?"))
  (when has-tag?
    (let* ((Event (js-field *js* "Event"))
	   (window (js-field *js* "window")))
      (Event.observe window "click" find-tag)
      )))

(define built-in-classes '(
			   "header-line"
			   "header-line-user"
			   "header-line-role"
			   "header-line-control"
			   "buffer"
			   "contents"
			   "linum"
			   "lfringe"
			   "rfringe"
			   ))

(define (wrong-tag-target? target)
  (or (any (lambda (class)
	     (target.hasClassName class))
	   built-in-classes)
      (target.hasClassName "comment")))

(define (symbol-at target)
  target.innerHTML)

(define (find-tag event)
  (let1 target event.target
    (unless (wrong-tag-target? target)
      (event.stop)
      (let ((symbol (symbol-at target))
	    (url (contents-url)))
	(require-tag url symbol major-mode target)
	))))

(define (contents-url)
  (let* ((location (js-field *js* "location"))
	 (pathname (js-field location "pathname")))
    (substring pathname
	       (string-length shell-dir)
	       (string-length pathname))))

(define (require-tag url symbol major-mode target-element)
  (let1 options (alist->object `((method . "get")
				 (parameters . ,(alist->object 
							 `((symbol . ,symbol)
							   (major-mode . (symbol->string major-mode))
							   ))
						     )
				 (onSuccess . ,(lambda (response)
						 (let1 es (read-from-response response)
						   (stitch es :target-element target-element)
						   ;;
						   )
						 ))))
    (js-new Ajax.Request
	    (string-append "/web/tag" url)
	    options)))
