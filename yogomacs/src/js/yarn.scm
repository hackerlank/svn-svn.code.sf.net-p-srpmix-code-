(define (stitch-yarn yarn)
  (let* ((yarn (cdr yarn))
	 (id (kref yarn :id #f)))
    (unless (member id stitch-ids)
      (let* ((target (kref yarn :target #f))
	     (content (kref yarn :content #f))
	     (date (kref yarn :date #f))
	     (full-name (kref yarn :full-name #f))
	     (mailing-address (kref yarn :mailing-address #f))
	     (subjects (kref yarn :subjects (list)))
	     (transited (kref yarn :transited #f))
	     )
	(let ((stitching-proc (stitch-choose-stitching-proc (car target)))
	      (render-proc (stitch-choose-render-proc (car content)))
	      ;;(filter-proc (stitch-make-filter-proc subjects))
	      )
	  (let1 shtml-frag  (render-proc id
					 (cadr content)
					 date
					 full-name
					 mailing-address
					 subjects
					 transited)
	    (when shtml-frag
	      (stitching-proc id (cadr target)
			      shtml-frag))))))))

(define (stitch-yarns yarns . rest)
  (for-each
     (lambda (elt)     
       (cond
	((eq? (car elt) 'yarn)
	 (stitch-yarn elt))))
     yarns))

(define-stitch yarn-container stitch-yarns)

(define (yarn-require url params)
  (let1 options (alist->object `((method . "get")
				 ,@(if params
				       `((parameters . ,params))
				       '())
				 (onSuccess . ,(lambda (response)
						 (stitch
						  (read-from-response response))
						 ))))
    (js-new Ajax.Request
	    (string-append "/web/yarn" url)
	    options)))