(define (tag-id-for tag)
  (let* ((tag (cdr tag))
	 (handler (kref tag :handler #f))
	 (target (kref tag :target #f))
	 (url (kref tag :url #f)))
    (html-escape-string
     (string-append (symbol->string handler) "/" (if (and target
							  (list? target)
							  (not (null? target)))
						     (cadr target)
						     (write-to-string target))
						     "@" url))))

(define (tag-render tag target-element)
  (let* ((id (tag-id-for tag))
	 (tag (cdr tag))
	 (handler (kref tag :handler #f))
	 (target (kref tag :target #f))
	 (url (kref tag :url #f))
	 (short-desc (kref tag :short-desc #f))
	 (desc (kref tag :desc #f))
	 (local? (kref tag :local? #f))
	 (score (kref tag :score #f))
	 (preview-url (kref tag :preview-url #f)))
    (let1 render-proc (stitch-choose-render-proc 'tag)
	  (render-proc id
		       handler
		       target
		       url
		       short-desc
		       desc
		       local?
		       score
		       preview-url))))

(define (tags-id-for symbol line)
  (string-append "T:" symbol "@" (write-to-string line)))
(define (stitch-tags tags . rest)
  (let* ((target-element (kref rest :target-element #f))
	 (symbol (kref rest :symbol "unknown"))
	 (line (kref rest :line #f))
	 (classes (kref rest :classes (list)))
	 (id (tags-id-for symbol line))
	 (tags (if (null? tags)
		   `((tag :handler null
			  :target (symbol ,symbol)
			  :url ""
			  :short-desc _
			  :desc "no tag"
			  :local? #f
			  :score 0))
		   tags)))
    (unless (stitched? id)
      (let ((rendered-tags (fold (lambda (elt result) 
				   (let1 r (tag-render elt target-element)
				     (if r (cons r result) result)))
				 (list)
				 tags))
	    (stitching-proc (stitch-choose-stitching-proc 'tag))
	    )
	(stitching-proc id ($ target-element)
			`(div (|@| (class "tags-div") (id ,id))
			      (div (|@| (class ,(string-append "tag-symbol-target"
							       " "
							       (apply string-append (intersperse 
										     " " 
										     (map symbol->string classes))
							       ))))
				   (a (|@| 
					(href "#") 
					(onclick ,(string-append "$('" 
								 (js-escape-string id)
								 "').hide();" )))
				       ,symbol))
			      ,@(reverse rendered-tags)))
	(for-each (lambda (tag)
		    (let* ((tag0 tag)
			   (tag (cdr tag))
			   (preview-url (kref tag :preview-url #f))
			   (preview-params (kref tag :preview-params '()))
			   )
		      (when preview-url
			(let1 id (tag-id-for tag0)
			  (load-lazy preview-url preview-params 
				     (string-append "v:" id)
				     #f)
			  )))
		    )
		  tags)
	))))

(define-stitch tag-container stitch-tags)

(define (tag-require url main-key symbol classes line major-mode target-element)
  (let* ((elt ($ target-element))
	 (parameters (alist->object 
		      `((main-key . ,(write-to-string main-key))
			(symbol . ,symbol)
			(line . ,(write-to-string line))
			(major-mode . ,(symbol->string major-mode))
			(classes . ,(write-to-string classes))
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
					       :symbol symbol
					       :line line
					       :classes classes)
				       )
				     (unhighlight elt)
				     (underline elt)
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
	(Event.observe window "click" tag-symbol-find)
	(Event.observe window "mousemove" tag-symbol-highlight)
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
  (define (is-part-of elt class)
    (let loop ((elt elt))
      (cond
       ((js-undefined? elt)
	#f)
       ((elt.hasClassName class)
	#t)
       (else
	(loop (elt.up 0))))))
  (let1 elt ($ target)
    (or (any (lambda (class)
	       (target.hasClassName class))
	     built-in-classes)
	(equal? target.tagName "A")
	(equal? target.tagName "a")
	(target.hasClassName "comment")
	;; (target.hasClassName "string")
	;; TODO: mode own class
	(is-part-of elt "yarn-div")
	(is-part-of elt "tags-div")
	(not (is-part-of elt "buffer"))
	(let1 str target.innerHTML
	  (every (lambda (c)
		   (memq c (major-mode-of 'separators)))
		 (string->list str)
		 )))))

(define tag-old-symbol-element #f)
(define tag-protected-symbol-elements (list))

(define (tag-split-target! target start end)
  (define (derive-element target start end)
    (let1 elt (let ((class (let1 elt ($ target) (elt.readAttribute "class")))
		    (id (string-append "P:" (+ (point-at target) start))))
		(js-new Element "span"
			(alist->object `((class . ,class)
					 (id . ,id)))))
      (elt.update (substring target.innerHTML start end))
      (cons elt (elt.identify))))
  (let* ((str target.innerHTML)
	 (len (string-length str)))
    (let1 elements (if (eq? start 0)
		       (if (eq? end len)
			   (list 
			    (cons target #t))
			   (list
			    (cons (derive-element target 0 end) #t)
			    (cons (derive-element target end len) #f))
			   )
		       (if (eq? end len)
			   (list
			    (cons (derive-element target 0 start) #f)
			    (cons (derive-element target start len) #t))
			   (list
			    (cons (derive-element target 0 start) #f)
			    (cons (derive-element target start end) #t)
			    (cons (derive-element target end len) #f)
			    )))
      (if (and (not (null? elements))
	       (eq? (car (car elements)) target))
	  target
	  (let loop ((elements (reverse (cons #f (reverse elements))))
		     (result #f))
	    (if (car elements)
		(let ((elt (car (car elements)))
		      (symbol-at? (cdr (car elements))))
		  (target.insert (alist->object `((before . ,(car elt)))))
		  (loop (cdr elements) (if symbol-at?
					   (cdr elt)
					   result)))
		(begin 
		  (target.remove)
		  ($ result))))))))


(define (tag-symbol-find event)
  (define (tag-event->offset-rate event)
    (let* ((point-px event.pageX)
	   (elt ($ event.target))
	   (offset-px (let1 o (elt.viewportOffset)
			o.left))
	   (width-px (elt.getWidth))
	   (offset-rate (/ (* 1.0 (- point-px offset-px))
			   width-px)))
      offset-rate))
  (unless (member tag-old-symbol-element
		  tag-protected-symbol-elements)
    (unhighlight tag-old-symbol-element))
  (let ((target event.target)
	(url (contents-url)))
    (unless (tag-wrong-target? target)
      (receive (symbol start end)
	  ((major-mode-of 'symbol-at) target (tag-event->offset-rate event))
	(event.stop)
	(let* ((target (tag-split-target! target start end))
	       (line (line-number-at target))
	       (id (tags-id-for symbol line)))
	  (if symbol
	      (cond
	       ((stitched? id)
		(let1 tag-elt ($ id)
		  (tag-elt.toggle)))
	       (else
		(set! tag-protected-symbol-elements
		      (cons ($ event.target) 
			    tag-protected-symbol-elements))
		(tag-require url 
			     'symbol
			     symbol
			     (classes-of target)
			     (line-number-at target)
			     major-mode
			     target)))
	      (alert "No symbol under point")))))))

(define (tag-symbol-highlight event)
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


