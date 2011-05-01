;(define (prependClassName elt class-name)
;  (let1 original-class-name (js-field elt "className")
;    (js-field-set! elt "className" class-name)
;    (elt.addClassName original-class-name)))

(define (highlight id)
  (let1 elt ($ id)
    (elt.addClassName "highlight")))
(export "yhl" highlight)
(define (unhighlight id)
  (let1 elt ($ id)
    (elt.removeClassName "highlight")))
(export "yuhl" unhighlight)

(define (jump-lazy hash)
  (when (and (string? hash)
	     (< 0 (string-length hash))
	     (eq? (string-ref hash 0) #\#))
    (let* ((id (substring hash 1 (string-length hash)))
	   (elt ($ id)))
      ;; Not portable
      (elt.scrollIntoView))))

(define (load-lazy)
  (define (load-lazy0 url params)
    (let1 options (alist->object `((method . "get")
				   (parameters . ,params)
				   (onFailure . ,(lambda ()
						   (alert "Error in load-lazy")))
				   (onComplete . ,(pa$ run-hook find-file-post-hook url params))))
      (js-new Ajax.Updater "buffer" url options)))
  (define (build-param meta-key param-name conv)
    (if-let1 v (read-meta meta-key)
	     `((,param-name . ,(conv v)))
	     `()))
  (define id (lambda (id) id))
  (let ((url (read-meta "next-path"))
	(params (alist->object
		 (append
		  (build-param "next-range" 'range id)
		  (build-param "next-enum"  'enum id)
		  (build-param "shell" 'shell symbol->string)))))
  (load-lazy0 url params)))

(define (focus) 
  (let1 elt ($ "minibuffer") 
    (elt.focus)
    (elt.select)))

(define meta-variables (make-hashtable))
(define (read-meta name)
  (let1 id ($ (string-append "E:" name))
    (let1 o (cond
	     ((hashtable-contains? meta-variables name)
	      (hashtable-get meta-variables name))
	     ((not (null? id))
	      (let* ((elt id)
		     (data (read-from-string elt.innerHTML)))
		(hashtable-put! meta-variables name data)
		(elt.remove)
		data)
	      )
	     (else
	      (let1 metas (vector->list ($$ "meta"))
		(let loop ((metas metas))
		  (if (null? metas)
		      #f
		      (if (equal? (js-field (car metas) "name") name)
			  (let1 data (read-from-string (js-field (car metas) "content"))
			    (begin
			      (hashtable-put! meta-variables name data)
			      data))
			  (loop (cdr metas))))))))
      o)))

(define (contents-url)
  (let* ((location (js-field *js* "location"))
	 (pathname (js-field location "pathname")))
    (substring pathname
	       (string-length shell-dir)
	       (string-length pathname))))

(add-hook! find-file-pre-hook load-lazy)
(add-hook! find-file-pre-hook header-line-init)
(add-hook! find-file-pre-hook repl-init)
(add-hook! find-file-pre-hook focus)

(add-hook! read-from-minibuffer-hook repl-read)

(add-hook! find-file-post-hook (lambda any (jump-lazy (js-field (js-field *js* "location") "hash"))))
(add-hook! find-file-post-hook require-yarn)
(add-hook! find-file-post-hook major-mode-init)
(add-hook! find-file-post-hook tag-init)

(add-hook! draft-box-abort-hook stitch-delete-draft-box)
(add-hook! draft-box-submit-hook stitch-submit)
(add-hook! toggle-full-screen-hook toggle-full-screen)
