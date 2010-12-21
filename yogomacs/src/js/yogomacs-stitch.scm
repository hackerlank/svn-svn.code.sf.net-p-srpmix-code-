;;;
;; Stitch
;;
(define stitch-ids (list))
(define (stitch-make-insertion-proc type)
  (cond
   ((eq? type 'file) 
    (lambda (id posinfo shtml-frag) 
      (let1 dom-id (string-append "L:" (number->string posinfo))
	(let1 elt ($ dom-id)
	  (when elt
	    (elt.insert 
	     (alist->object `((before . ,(sxml->xhtml shtml-frag)))))
	    (set! stitch-ids (cons id stitch-ids)))))))
   ((eq? type 'directory) 
    (lambda (id posinfo shtml-frag) 
      (let1 dom-id (string-append "N:" posinfo)
	(let1 elt ($ dom-id)
	  (when elt
	    (elt.insert 
	     (alist->object `((before . ,(sxml->xhtml shtml-frag)))))
	    (set! stitch-ids (cons id stitch-ids)))))))
   (else (lambda (posinfo shtml-frag) #f))))

(define (stitch-text-render id text date full-name mailing-address subjects transited-from)
  `(div (|@|
	 (class "yarn-div")
	 (id ,(string-append "S:" id))
	 )
	(div (|@|
	      (class "yarn-header"))
	     (span (|@| 
		    (class "yarn-date-face"))
		   ,(or date
			(let1 d (js-new Date)
			  (string-append
			   (d.getFullYear) "-" (+ (d.getMonth) 1) "-" (d.getDate))
			  )))
	     "  "
	     (span  (|@| (class "yarn-name"))
		    ,full-name)
	     "  "
	     "<"
	     (span  (|@| (class "yarn-email"))
		    ,mailing-address)
	     ">"
	     )
	(div (|@| 
	      (class "yarn-content"))
	     (span  (|@| (class ,(if transited-from
				     "yarn-text yarn-transited"
				     "yarn-text"
				     )))
		    ,(if transited-from
			 `(a (|@| (href ,(if shell-dir
					     (string-append shell-dir
							    (car transited-from))
					     (car transited-from))))
			     ,text)
			 text)))
	(div (|@|
	      (class "yarn-footer"))
	     (div
	      (span ,(write-to-string subjects)))
	     )))

(define (stitch-draft-text-render subjects)
  `(div (|@|
	 (class "yarn-div")
	 (id "yarn-draft-box")
	 )
	(div (|@| 
	      (class "yarn-content"))
	     (textarea (|@|
			(rows "2")
			(class "yarn-draft")
			(id "yarn-draft"))
		       ""
		       ))
	(div (|@|
	      (class "yarn-footer"))
	     (div
	      "["
	      (a (|@| (href "#") (onclick "run_draft_box_abort_hook();")) "Abort")
	      "]["
	      (a (|@| (href "#") (onclick "run_draft_box_submit_hook('text');")) "Submit")
	      "]"
	      (span ,(write-to-string subjects))
	      )
	     )))
  
(define (stitch-make-render-proc type)
  (cond
   ((eq? type 'draft-text) stitch-draft-text-render)
   ((eq? type 'text) stitch-text-render)
   (else (lambda rest
	   #f))))

(define (stitch-yarn elt)
  (let* ((elt (cdr elt))
	 (id (kref elt :id #f)))
    (unless (member id stitch-ids)
      (let* ((target (kref elt :target #f))
	     (content (kref elt :content #f))
	     (date (kref elt :date #f))
	     (full-name (kref elt :full-name #f))
	     (mailing-address (kref elt :mailing-address #f))
	     (subjects (kref elt :subjects (list)))
	     (transited (kref elt :transited #f))
	     )
	(let ((insertion-proc (stitch-make-insertion-proc (car target)))
	      (render-proc (stitch-make-render-proc (car content)))
					;(filter-proc (stitch-make-filter-proc subjects))
	      )
	  (let1 shtml-frag  (render-proc id
					 (cadr content)
					 date
					 full-name
					 mailing-address
					 subjects
					 transited)
	    (when shtml-frag
	      (insertion-proc id (cadr target)
			      shtml-frag))))))))

(define (stitch-yarns yarns)
  (cond 
   ((eq? (car yarns) 'yarn-container)
    (for-each
     (lambda (elt)     
       (cond
	((eq? (car elt) 'yarn)
	 (stitch-yarn elt))))
     (cdr yarns)
     ))))


(define (require-yarns url params)
  (let1 options (alist->object `((method . "get")
				 ,@(if params
				       `((parameters . ,params))
				       '())
				 (onSuccess . ,(lambda (response)
						 (stitch-yarns
						  (read-from-response response))
						 ))))
    (js-new Ajax.Request
	    (string-append "/web/yarn" url)
	    options)))

(define stitch-draft-target #f)
(define (stitch-prepare-draft-text-box lfringe)
  (define (target-for obj)
    (let1 prev (obj.previous)
      (let1 id (prev.identify)
	(cond
	 ((and (eq? (string-ref id  0) #\N)
	       (eq? (string-ref id  1) #\:))
	  `(directory . ,(substring id 2 (string-length id))))
	 ((and (eq? (string-ref id  0) #\L)
	       (eq? (string-ref id  1) #\:))
	  `(file . ,(substring id 2 (string-length id))))
	 (else
	  #f)))))
  (cond
   (stitch-draft-target
    (alert "You can open only one Draft Box at once"))
   (else
    (let1 target (target-for lfringe)
      (if target
	  (let1 prev (lfringe.previous)
	    (prev.insert
	     (alist->object 
	      `((before . ,(sxml->xhtml ((stitch-make-render-proc 'draft-text)
					 '("*DRAFT*")
					 ))))))
	    (set! stitch-draft-target target))
	  (alert "INTERNAL ERROR: Cannot determine target"))))))


(define (stitch-delete-draft-box)
  (set! stitch-draft-target #f)
  (let1 elt ($ "yarn-draft-box")
    (elt.remove)))

(define (stitch-submit type)
  (let* ((location (js-field *js* "location"))
	 (pathname (js-field location "pathname"))
	 (hash     (js-field location "hash"))
	 (url      (substring pathname
			      (string-length shell-dir)
			      (string-length pathname))))
    (let1 options (alist->object 
		   `((method . "post")
		     (parameters . ,(alist->object
				     `((stitch . ,((js-field *js* "encodeURIComponent")
						   (write-to-string
						    `(yarn-container 
						      (yarn :version 0 
							    :target ,stitch-draft-target
							    :content (text ,(<- "yarn-draft"))
							    :subjects ("*DRAFT*")))))))))
		     (onSuccess . ,(lambda (response)
				     (require-yarns url #f)
				     (stitch-delete-draft-box)
				     ))))
      (js-new Ajax.Request
	      (string-append "/web/yarn" url)
	      options))))

