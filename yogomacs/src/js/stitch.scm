;;;
;; Stitch
;;
(define stitch-ids (list))

;;
;; Stitchers
;;
(define (stitch-file-stitching-proc id posinfo shtml-frag)
  (let1 dom-id (string-append "L:" (number->string posinfo))
    (let1 elt ($ dom-id)
      (if elt
	  (begin
	    (elt.insert 
	     (alist->object `((before . ,(sxml->xhtml shtml-frag)))))
	    id)
	  #f))))

(define (stitch-directory-stitching-proc id posinfo shtml-frag)
  (let1 dom-id (string-append "N:" posinfo)
    (let1 elt ($ dom-id)
      (if elt
	  (begin
	    (elt.insert 
	     (alist->object `((before . ,(sxml->xhtml shtml-frag)))))
	    id)
	  #f))))

(define (stitch-tag-stitching-proc id posinfo shtml-frag)
  (let1 elt (posinfo.next ".linum")
    (if (js-undefined? elt)
	(let loop ((elt posinfo))
	  (let1 next (elt.next)
	    (if (js-undefined? next)
		(elt.insert
		 (alist->object `((after . ,(sxml->xhtml shtml-frag)))))
		(loop next))))
	(elt.insert
	 (alist->object `((before . ,(sxml->xhtml shtml-frag))))))
    id))

(define (stitched? id)
  (member id stitch-ids))
(define (stitch-choose-stitching-proc type)
  (let1 proc
      (cond
       ((eq? type 'file) stitch-file-stitching-proc)
       ((eq? type 'directory) stitch-directory-stitching-proc)
       ((eq? type 'tag) stitch-tag-stitching-proc)
       (else (lambda (id posinfo shtml-frag) #f)))
    (lambda (id posinfo shtml-frag)
      (let1 id (proc id posinfo shtml-frag)
	(when id
	  (set! stitch-ids (cons id stitch-ids)))))))

;;
;; Renderer
;;
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
			 `(a (|@| (href ,(if *shell-dir*
					     (string-append *shell-dir*
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
	      (a (|@| (href "#") (onclick "run_draft_box_abort_hook();")) "abort")
	      "]["
	      (a (|@| (href "#") (onclick "run_draft_box_submit_hook('text');")) "submit")
	      "]"
	      (span ,(write-to-string subjects))
	      )
	     )))

(define (sttich-tag-render id
			   handler
			   target
			   url
			   short-desc
			   desc
			   local?
			   score)
  `(div (|@|
	 (class "tag-div")
	 (id ,(string-append "t:" id)))
	(div
	 (span (|@| (class "tag-handler-span"))
	       (span (|@| (class "tag-handler")) ,(symbol->string handler)) 
	       "/" 
	       (span (|@| (class "tag-score")) ,(number->string score)))
	 (span (|@| (class "tag-desc")) ,(if desc
					     desc
					     (symbol->string short-desc))))
	(div
	 (a (|@| 
	    (href ,(if local?
		       (string-append *shell-dir* url)
		       url)))
	   ,url))
	))

(define (stitch-choose-render-proc type)
  (cond
   ((eq? type 'draft-text) stitch-draft-text-render)
   ((eq? type 'text) stitch-text-render)
   ((eq? type 'tag) sttich-tag-render)
   (else (lambda rest
	   #f))))

(define stitch-proc-table (make-hashtable))
(define-macro (define-stitch key proc)
  `(hashtable-put! stitch-proc-table  (quote ,key) ,proc))

(define (stitch data . rest)
  (let1 proc (hashtable-get stitch-proc-table (car data))
    (if proc
	(apply proc (cdr data) rest)
	;; TODO: What I should do???
	#f)))

;;
;; Submitting
;;
(define stitch-draft-target #f)
(define (stitch-prepare-draft-text-box lfringe)
  (define (target-for obj)
    (let1 prev (obj.previous)
      (let1 id (prev.identify)
	(cond
	 ((and (eq? (string-ref id  0) #\N)
	       (eq? (string-ref id  1) #\:))
	  `(directory . ,(substring-after id 2)))
	 ((and (eq? (string-ref id  0) #\L)
	       (eq? (string-ref id  1) #\:))
	  `(file . ,(substring-after id 2)))
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
	      `((before . ,(sxml->xhtml ((stitch-choose-render-proc 'draft-text)
					 '("*DRAFT*")
					 ))))))
	    (set! stitch-draft-target target))
	  (alert "INTERNAL ERROR: Cannot determine target"))))))


(define (stitch-delete-draft-box)
  (set! stitch-draft-target #f)
  (let1 elt ($ "yarn-draft-box")
    (elt.remove)))

(define (stitch-submit type)
  (let* ((hash     (js-field (js-field *js* "location") "hash"))
	 (url      (contents-url))
	 (yarn     `(yarn :version 0 
			  :target ,stitch-draft-target
			  :content (text ,(<- "yarn-draft"))
			  :subjects ("*DRAFT*")))
	 (yarn-str (write-to-string `(yarn-container ,yarn)))
	 (parameters (alist->object
		      `((stitch . ,((js-field *js* "encodeURIComponent") yarn-str))))))
    (let1 options (alist->object 
		   `((method . "post")
		     (parameters . ,parameters)
		     (onSuccess . ,(lambda (response)
				     (yarn-require url #f)
				     (stitch-delete-draft-box)
				     ))))
      (js-new Ajax.Request
	      (string-append "/web/yarn" url)
	      options))))

