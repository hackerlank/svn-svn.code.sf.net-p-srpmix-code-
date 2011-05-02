(define (stitch-tag tag target-element)
  (let* ((tag (cdr tag))
	 (handler (kref tag :handler #f))
	 (target (kref tag :target #f))
	 (url (kref tag :url #f))
	 (short-desc (kref tag :short-desc #f))
	 (desc (kref tag :desc #f))
	 (local? (kref tag :local? #f))
	 (score (kref tag :score #f))
	 (id (string-append (symbol->string handler) "/" target "@" url)))
    (unless (member id stitch-ids)
      (let ((stitching-proc (stitch-choose-stitching-proc 'tag))
	    (render-proc (stitch-choose-render-proc 'tag)))
	(let1 shtml-frag (render-proc id
				      handler
				      target
				      url
				      short-desc
				      desc
				      local?
				      score)
	  (when shtml-frag
	    (stitching-proc id ($ target-element) shtml-frag)))))))

(define (stitch-tags tags . rest)
  (let ((target-element (kref rest :target-element #f))
	(symbol (kref rest :symbol "unknown")))
    (if (null? tags)
	(stitch-tag `(tag :handler null
			  :target ,symbol
			  :url ""
			  :short-desc _
			  :desc "no tag"
			  :local? #f
			  :score 0) 
		    target-element)
	(for-each
	 (lambda (elt)
	   (cond
	    ((eq? (car elt) 'tag)
	     (stitch-tag elt target-element))
	    ))
	 tags))))

(define-stitch tag-container stitch-tags)

(define (tag-require url symbol major-mode target-element)
  (let* ((elt ($ target-element))
	 (parameters (alist->object 
		      `((symbol . ,symbol)
			(major-mode . (symbol->string major-mode))
			)))
	 (options (alist->object 
		   `((method . "get")
		     (parameters . ,parameters)
		     (onFailure . ,(lambda (response json)
				     (unhighlight elt)
				     ))
		     (onSuccess . ,(lambda (response json)
				     (let1 es (read-from-response response)
				       (stitch es 
					       :target-element target-element
					       :symbol symbol)
				       )
				     (unhighlight elt)
				     (set! tag-protected-symbol-elements 
					   (delete elt
						   tag-protected-symbol-elements))
				     ))
		     ))))
    (highlight elt)
    (js-new Ajax.Request
	    (string-append "/web/tag" url)
	    options)))

(define (tag-init . any)
  (let1 has-tag? (read-meta "has-tag?")
    (when has-tag?
      (let* ((Event (js-field *js* "Event"))
	     (window (js-field *js* "window")))
	(Event.observe window "click" tag-find)
	(Event.observe window "mousemove" tag-highlight)
	))))

(define (tag-wrong-target? target)
  (define built-in-classes '(
			     "header-line"
			     "header-line-user"
			     "header-line-role"
			     "header-line-control"
			     ;;
			     "modeline"
			     "modeline-control"
			     "minibuffer-shell"
			     "minibuffer"
			     "minibuffer-prompt-shell"
			     "minibuffer-prompt"
			     ;;
			     "buffer"
			     "contents"
			     "linum"
			     "lfringe"
			     "rfringe"
			     ))
  (let1 elt ($ target)
    (or (any (lambda (class)
	       (target.hasClassName class))
	     built-in-classes)
	(equal? target.tagName "A")
	(equal? target.tagName "a")
	(target.hasClassName "comment")
	(let loop ((elt elt))
	  (cond
	   ((js-undefined? elt)
	    #f)
	   ((elt.hasClassName "yarn-div")
	    #t)
	   (else
	    (loop (elt.up 0))))))))

(define tag-old-symbol-element #f)
(define tag-protected-symbol-elements (list))
(define (tag-find event)
  (unless (member tag-old-symbol-element
		  tag-protected-symbol-elements)
    (unhighlight tag-old-symbol-element))
  (let1 target event.target
    (let* ((point-px event.pageX)
	   (elt ($ target))
	   (offset-px (let1 o (elt.viewportOffset)
			o.left))
	   (width-px (elt.getWidth))
	   (offset-rate (/ (* 1.0 (- point-px offset-px))
			   width-px)))
      (unless (tag-wrong-target? target)
	(let ((symbol ((major-mode-of 'symbol-at) target offset-rate)))
	  ;; event, url symbol, *major-mode*, target
	  (let1 url (contents-url)
	    (event.stop)
	    (if symbol
		(begin
		  (set! tag-protected-symbol-elements 
			(cons elt tag-protected-symbol-elements))
		  (tag-require url symbol major-mode target))
		(alert "No symbol under point")
		)))))))

(define (tag-highlight event)
  (unless (member tag-old-symbol-element
		  tag-protected-symbol-elements)
    (unhighlight tag-old-symbol-element))
  (let1 target event.target
    (let1 elt ($ target)
      (unless (tag-wrong-target? target)
	(set! tag-old-symbol-element elt)
	  (unless (member tag-old-symbol-element
				 tag-protected-symbol-elements)
	    (highlight tag-old-symbol-element))))))
