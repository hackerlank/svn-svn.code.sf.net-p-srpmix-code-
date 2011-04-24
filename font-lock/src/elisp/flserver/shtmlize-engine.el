(require 'xhtmlize)
(require 'cssize)
(require 'cl)
(require 'queue-m)

(defclass <shtmlize-engine>  (<xhtmlize-common-engine>)
  ())

(define-xhtmlize-engine 'shtmlize <shtmlize-engine>)

(defconst shtmlize-major-version 0)
(defconst shtmlize-minor-version 0)
(defconst shtmlize-micro-version 0)

(defun shtmlize-make-file-name (file)
  (concat file ".shtml"))

(defsubst shtmlize-top (engine)
  (car (oref engine canvas)))
(defsubst shtmlize-push (engine)
  (let ((new (queue-create))
	(old (shtmlize-top engine)))
    (queue-enqueue old new)
    (oset engine canvas (cons new (oref engine canvas)))
    new))
(defsubst shtmlize-pop (engine)
  (let ((old (shtmlize-top engine)))
    (oset engine canvas (cdr (oref engine canvas)))
    (shtmlize-top engine)))

(defsubst shtmlize-enqueue (queue elts)
  (mapc
   (lambda (elt)
     (queue-enqueue queue elt))
   elts))

(defun shtmlize-expand-0 (queue)
  (let* ((as-list (queue-all queue))
	 (temp as-list))
    (while temp
      (when (queue-p (car temp))
	(setcar temp (shtmlize-expand-0 (car temp))))
      (setq temp (cdr temp)))
    as-list))

;; (defun shtmlize-expand-0 (queue)
;;   (mapcar
;;    (lambda (elt)
;;      (cond
;;       ((queue-p elt) (shtmlize-expand-0 elt))
;;       ;((and (stringp elt) (string= elt "\n")) "\\n")
;;       (t elt)))
;;    (queue-all queue)))

(defun shtmlize-expand (engine)
  (shtmlize-expand-0 (shtmlize-top engine)))
(defun shtmlize-enqueue-text-with-id (text id href fstruct-list engine)
  (let ((queue (shtmlize-top engine))
	(single (and (car fstruct-list) (null (cdr fstruct-list)))))
    (if single
	(shtmlize-enqueue queue `((span
				   (|@|
				    (class ,(cssize-fstruct-css-name (car fstruct-list)))
				    ,@(if id
					  `((id ,id))
					()))
				   ,(if href
					`(a (|@| (href ,href))
					    ,text)
				      text))))
      (let ((temp fstruct-list)
	    fstruct)
	(while temp
	  (setq fstruct (car temp)
		temp (cdr temp)
		queue (shtmlize-push engine))
	  (shtmlize-enqueue queue `(span
				    (|@|
				     (class ,(cssize-fstruct-css-name fstruct))
				     ,@(if id
					   `((id ,id))
					 ()))
				    ,@(if temp
					  ()
					;; No rest span, make A inline.
					(if href
					    `(
					      (a (|@| (href ,href))
						 ,text)
					      )
					  `(,text))))))))
    (unless fstruct-list
      (when href
	(setq queue (shtmlize-push engine))
	(shtmlize-enqueue queue
			  `(a (|@| (href ,href)))))
      (shtmlize-enqueue queue (list text))
      (when href
	(setq queue (shtmlize-pop engine))))
    
    (unless single
      (dolist (fstruct fstruct-list)
	(setq queue (shtmlize-pop engine))))))

(defmethod xhtmlize-engine-prepare ((engine <shtmlize-engine>))
  (call-next-method)
  (oset engine
	canvas (list (queue-create))))
		  
(defmethod xhtmlize-engine-prologue ((engine <shtmlize-engine>) title)
  (let ((queue (shtmlize-top engine)))
    (shtmlize-enqueue 
     queue
     `(*TOP* 
       (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"") "\n"
       (*DECL* DOCTYPE html PUBLIC 
	       "-//W3C//DTD XHTML 1.0 Transitional//EN"
	       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
       "\n"
       (*COMMENT* ,(format " Created by xhtmlize-%s in external-css mode. " xhtmlize-version))
       ,@(mapcar
	  (lambda (comment)
	    `(*COMMENT* ,comment))
	  (reverse (oref engine early-comments)))
       "\n"))
    (oset engine prepared-p t)

    (setq queue (shtmlize-push engine))
    (shtmlize-enqueue queue
		      '(html 
			(|@| (xmlns "http://www.w3.org/1999/xhtml") (xml:lang "en") (lang "en"))
			"\n"))

    (setq queue (shtmlize-push engine))
    (shtmlize-enqueue queue 
		      `(head 
			"\n"
			"    " (title ,title)
			"\n")) 
    ;; TODO: do this in plugin (http-equivcontent-type, charset, expires...)
    (mapc
     (lambda (elt)
       (shtmlize-enqueue
	queue
	`("    " (meta (|@| (name ,(car elt))
			    (content ,(cdr elt))
			    ))
	  "\n"))
       )
     `(("major-mode" . ,(symbol-name major-mode))
       ("created-time" . ,(format-time-string "%Y-%m-%dT%T"))
       ("version" . ,(format "%d.%d.%d"
			     shtmlize-major-version
			     shtmlize-minor-version
			     shtmlize-micro-version))
       ("point-max" . ,(format "%d" (point-max)))
       ("count-lines" . ,(format "%d" (count-lines (point-min) 
						   (point-max))))
       ))

    (lexical-let ((queue queue))
	(dolist (face (xhtmlize-external-css-enumerate-faces (oref engine buffer-faces)
							     (oref engine face-map)))
	  (when (xhtmlize-css-link face 
				   xhtmlize-external-css-base-dir
				   (lambda (face title)
				     (shtmlize-enqueue
				      queue
				      `("    " (link (|@| (rel "stylesheet")
							  (type "text/css")
							  (href ,(format "%s/%s"
									 xhtmlize-external-css-base-url
									 (xhtmlize-css-make-file-name face
												      title)))
							  (title ,title)))
					"\n"))))
	    (oset engine wrote-css-p t))))
    ;;
    (setq queue (shtmlize-pop engine))
    (shtmlize-enqueue queue '("\n" "    "))
    ))

(defmethod xhtmlize-engine-body ((engine <shtmlize-engine>))
  (let ((queue (shtmlize-top engine)))
    (setq queue (shtmlize-push engine))
    (shtmlize-enqueue queue '(body "\n" "    "))
    (setq queue (shtmlize-push engine))
    (shtmlize-enqueue queue '(pre "\n"))
        
    (xhtmlize-engine-body-common engine
				 #'shtmlize-enqueue-text-with-id
				 )
    
    (setq queue (shtmlize-pop engine))
    (shtmlize-enqueue queue '("\n" "    "))
    (setq queue (shtmlize-pop engine))
    (shtmlize-enqueue queue '("\n"))))

(defmethod xhtmlize-engine-epilogue ((engine <shtmlize-engine>))
  (let ((queue (shtmlize-top engine))) 
    (shtmlize-enqueue (shtmlize-pop engine) '("\n"))))

(defmethod xhtmlize-engine-process ((engine <shtmlize-engine>))
  (let ((buf (generate-new-buffer (if (buffer-file-name)
				      (shtmlize-make-file-name
				       (file-name-nondirectory
					(buffer-file-name)))
				    "*shtml*")))
	(print-escape-newlines t))
    (buffer-disable-undo buf)
    (prin1 (shtmlize-expand engine) buf)
    buf))

(defmethod xhtmlize-engine-insert-comment ((engine <shtmlize-engine>) 
					   comment)
  (if (oref engine prepared-p)
      (let ((queue (shtmlize-top engine)))
	(shtmlize-enqueue queue `((*COMMENT* ,comment))))
    (call-next-method)))

(defmethod xhtmlize-engine-make-file-name ((engine <shtmlize-engine>) file)
  (concat file ".shtml"))

(provide 'shtmlize-engine)

