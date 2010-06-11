(require 'xhtmlize)
(require 'cssize)
(require 'cl)
(require 'queue-m)

(defclass <shtmlize-engine>  (<xhtmlize-common-engine>)
  ())

(define-xhtmlize-engine 'shtmlize <shtmlize-engine>)

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
  (mapcar
   (lambda (elt)
     (cond
      ((queue-p elt) (shtmlize-expand-0 elt))
      ;((and (stringp elt) (string= elt "\n")) "\\n")
      (t elt)))
   (queue-all queue)))

(defun shtmlize-expand (engine)
  (shtmlize-expand-0 (shtmlize-top engine)))

(defun shtmlize-enqueue-text-with-id (text id href fstruct-list engine)
  (let ((queue (shtmlize-top engine)))
    (dolist (fstruct fstruct-list)
      (setq queue (shtmlize-push engine))
      (shtmlize-enqueue queue '(span))
      (setq queue (shtmlize-push engine))
      (shtmlize-enqueue queue `(|@|
				(class ,(cssize-fstruct-css-name (car fstruct-list)))
				,@(if id
				      `((id ,id))
				    ())
				))
      (setq queue (shtmlize-pop engine))
      )
    (when href
      (setq queue (shtmlize-push engine))
      (shtmlize-enqueue queue
			`(a (|@| (href ,href)))))

    (shtmlize-enqueue queue (list text))

    (when href
      (setq queue (shtmlize-pop engine)))
    
    (dolist (fstruct fstruct-list)
      (setq queue (shtmlize-pop engine)))))

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
       "\n"))

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

    (lexical-let ((queue queue))
      (dolist (face (xhtmlize-external-css-enumerate-faces (oref engine buffer-faces)
							   (oref engine face-map)))
	(xhtmlize-css-link face 
			   xhtmlize-external-css-base-dir
			   (lambda (face title)
			     (shtmlize-enqueue
			      queue
			      `("    " (link (|@| (rel "stylesheet")
						  (type "text/css")
						  (href ,(format "%s/%s"
								 xhtmlize-external-css-base-url
								 (xhtmlize-css-make-file-name face title)))
						  (title ,title)))
				"\n"))))))
    
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
  (setq queue (shtmlize-pop engine))
  (shtmlize-enqueue queue '("\n")))

(defmethod xhtmlize-engine-process ((engine <shtmlize-engine>))
  (let ((buf (generate-new-buffer (if (buffer-file-name)
				      (shtmlize-make-file-name
				       (file-name-nondirectory
					(buffer-file-name)))
				    "*shtml*")))
	(print-escape-newlines t))
    (prin1 (shtmlize-expand engine) buf)
    buf))
(provide 'shtmlize-engine)

