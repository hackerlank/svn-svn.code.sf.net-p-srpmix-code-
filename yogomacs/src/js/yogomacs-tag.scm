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

(define (require-tag url symbol major-mode target-element)
  (let* ((parameters (alist->object 
		      `((symbol . ,symbol)
			(major-mode . (symbol->string major-mode))
			)))
	 (options (alist->object 
		   `((method . "get")
		     (parameters . ,parameters)
		     (onSuccess . ,(lambda (response)
				     (let1 es (read-from-response response)
				       (stitch es 
					       :target-element target-element
					       :symbol symbol)
				       )))))))
    
    (js-new Ajax.Request
	    (string-append "/web/tag" url)
	    options)))
