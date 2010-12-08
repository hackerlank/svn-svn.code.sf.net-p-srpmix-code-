;;;
;; Stitch
;;
(define (stitch-make-insertion-proc type)
  (cond
   ((eq? type 'file) (lambda (posinfo shtml-frag) 
		       (let1 id (string-append "L:" (number->string posinfo))
			 (let1 elt ($ id)
			   (when elt
			     (elt.insert 
			      (alist->object `((before . ,(sxml->xhtml shtml-frag))))))))))
   ((eq? type 'directory) (lambda (posinfo shtml-frag) 
			    (let1 id (string-append "N:" posinfo)
			      (let1 elt ($ id)
				(when elt
				  (elt.insert 
				   (alist->object `((before . ,(sxml->xhtml shtml-frag))))))))))
   (else (lambda (posinfo shtml-frag) #f))))

(define (stitch-text-render text date full-name mailing-address subjects transited-from)
  `(div (|@|
	 (class "yarn-div")
					;(id ...)
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
			     (class "yarn-draft"))
			    ""
			    ))
	(div (|@|
	      (class "yarn-footer"))
	     (div
	      (a (|@| (href "#") (onclick "run_draft_box_abort_hook();")) "Abort")
	      " "
	      (a (|@| (href "#") (onclick "run_draft_box_submit_hook();")) "Submit")
	      " "
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
  (let1 elt (cdr elt)
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
	(let1 shtml-frag  (render-proc #f ;id
				       (cadr content)
				       date
				       full-name
				       mailing-address
				       subjects
				       transited)
	  (when shtml-frag
		(insertion-proc (cadr target)
				shtml-frag)))))))

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
				 (parameters . ,params)
				 (onSuccess . ,(lambda (response)
						 (stitch-yarns
						  (read-from-response response))
						 ))))
    (js-new Ajax.Request
	    (string-append "/web/yarn" url)
	    options)))

(define stitch-draft-box #f)
(define (stitch-prepare-draft-text-box lfringe)
  (if stitch-draft-box
      (alert "You can open only one Draft Box at once")
      (let1 prev (lfringe.previous)
	(prev.insert
	 (alist->object 
	  `((before . ,(sxml->xhtml ((stitch-make-render-proc 'draft-text)
				     '("*DRAFT*")
				     ))))))
	(set! stitch-draft-box #t))))

(define (stitch-delete-draft-box)
  (set! stitch-draft-box #f)
  (let1 elt ($ "yarn-draft-box")
    (elt.remove)))
