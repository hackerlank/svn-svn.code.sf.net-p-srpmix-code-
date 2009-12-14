(require 'dive-tokenize)
(require 'cl)

(defun dive-valley-estimate-depth (token)
  (let ((depth 1)
	(max-depth 0))
    (mapc
     (lambda (token)
       (case (dive-tokenize-token-type token)
	 ('open
	  (setq depth (1+ depth))
	  (when (< max-depth depth)
	    (setq max-depth depth)))
	 ('close
	  (setq depth (1- depth)))))
     token)
    max-depth))

(defun dive-valley-pair-p (open-char close-char)
  (case open-char
    (?\(
     (eq close-char ?\)))
    (?\{
     (eq close-char ?}))
    (?\[  
     (eq close-char ?\]))
    (?\< 
     (eq close-char ?\>))))

(defconst dive-valley-marker (propertize "@"
					 'face 'mode-line-inactive))
(defun dive-valley-show (valley current-depth)
  (let ((l (length valley)))
    (cond
     ((eq current-depth 0)
      l)
     ((>= current-depth l)
      l)
     ((eq  (1+ current-depth) l)
      (let ((vs (aref valley current-depth)))
	(mapc
	 (lambda (v)
	   (let ((o (aref v 2)))
	     (when o
	       (overlay-put o 'invisible nil)
	       (overlay-put o 'before-string nil)
	       )))
	 vs))
      l)
     (t
      (let ((vs (aref valley current-depth)))
	(mapc
	 (lambda (v)
	   (let ((o (aref v 2)))
	     (when o
	       (overlay-put o 'invisible nil)
	       (overlay-put o 'before-string nil)
	       )))
	 vs))
      (let ((vs (aref valley (1+ current-depth))))
	(mapc
	 (lambda (v)
	   (let ((o (or (aref v 2)
			(let ((o (make-overlay (1- (dive-tokenize-token-end (aref v 0))) ;dirty
					       (1- (dive-tokenize-token-start (aref v 1))))))
			  (aset v 2 o)
			  o))))
	     (unless  (dive-tokenize-token-aget (aref v 0) 'after-keyword)
	       (overlay-put o 'invisible t)
	       (unless (eq (dive-tokenize-token-end (aref v 0))
			   (dive-tokenize-token-start (aref v 1)))
		 (overlay-put o 'before-string dive-valley-marker)))
	     ))
	 vs))
      (1+ current-depth)
      )
     )))

(defun dive-valley-hide (valley current-depth)
  (let ((l (length valley)))
    (cond
     ((eq current-depth 0)
      (setq current-depth l)
      (dive-valley-hide valley l))
     ((eq current-depth 1)
      1)
     ((eq current-depth l)
      (let ((vs (aref valley (1- l))))
	(mapc
	 (lambda (v)
	   (let ((o (or (aref v 2)
			(let ((o (make-overlay (1- (dive-tokenize-token-end (aref v 0))) ;dirty
					       (1- (dive-tokenize-token-start (aref v 1))))))
			  (aset v 2 o)
			  o))))
	     (unless  (dive-tokenize-token-aget (aref v 0) 'after-keyword)
	       (overlay-put o 'invisible t)
	       (unless (eq (dive-tokenize-token-end (aref v 0))
			   (dive-tokenize-token-start (aref v 1)))
		 (overlay-put o 'before-string dive-valley-marker)))
	     ))
	 vs))
      (1- l))
     (t
      (let ((vs (aref valley current-depth)))
	(mapc
	 (lambda (v)
	   (let ((o (aref v 2)))
	     (when o
	       (overlay-put o 'invisible nil)
	       (overlay-put o 'before-string nil)
	       )))
	 vs))
      (let ((vs (aref valley (1- current-depth))))
	(mapc
	 (lambda (v)
	   (let ((o (or (aref v 2)
			(let ((o (make-overlay (1- (dive-tokenize-token-end (aref v 0))) ;ditry
					       (1- (dive-tokenize-token-start (aref v 1))))))
			  (aset v 2 o)
			  o))))
	     (unless  (dive-tokenize-token-aget (aref v 0) 'after-keyword)
	       (overlay-put o 'invisible t)
	       (unless (eq (dive-tokenize-token-end (aref v 0))
			   (dive-tokenize-token-start (aref v 1)))
		 (overlay-put o 'before-string dive-valley-marker)))
	     ))
	 vs))
      (1- current-depth)))))

(defun dive-valley-new (tokens buffer)
  (catch 'unblance-sytax
    (let ((stack (list))
	  (depth 0)
	  (valley (make-vector 
		   (dive-valley-estimate-depth tokens)
		   nil))
	  (after-keyword nil))
      (mapc
       (lambda (token)
	 (case (dive-tokenize-token-type token)
	   ('keyword
	    (when (memq  (dive-tokenize-token-expression token)
			 '(if while for))
	      (setq after-keyword t)
	      )
	    )
	   ('open
	    (push token stack)
	    (setq depth (1+ depth))
	    (when after-keyword
	      (dive-tokenize-token-aput token 'after-keyword t))
	    (setq after-keyword nil)
	    )
	   ('close
	    (setq after-keyword nil)
	    (let ((close token)
		  (open  (pop stack)))
	      (if (and open 
		       (dive-valley-pair-p 
			(dive-tokenize-token-expression open)
			(dive-tokenize-token-expression close)))
		  (aset valley depth
			(cons  `[,open ,close ,nil] (aref valley depth)))
		(throw 'unblance-sytax nil))
	      (setq depth (1- depth))))
	   (t
	    (setq after-keyword nil))
	   ))
       tokens)
      (if (and (zerop depth)
	       (null stack))
	  valley
	nil))))

(provide 'dive-valley)