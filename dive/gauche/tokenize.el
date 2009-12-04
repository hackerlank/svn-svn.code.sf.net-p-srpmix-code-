(defun tx-can-go-down   (s)
  (memq (string-to-char s) '(?\( ?\{ ?\[))  
  )

(defun tx-calibrate-pos ()
  (forward-sexp 1)
  (backward-sexp 1))

(defun tx-token (str b e)
  (vector str b e))

(defun tx-get-expressions00 (bias)
  (tx-calibrate-pos)
  (let ((p (point)))
    (forward-sexp 1)
    (let ((s (buffer-substring-no-properties p (point))))
      (cond
       ((eobp)
	(list (tx-token s
			(+ p bias)
			(+ (point) bias))))
       ((tx-can-go-down s)
	;;	(tx-get-expressions0 (substring s 1 -1) (+ (+ (- p 1) 1) bias) t)
	(let ((p+ (+ p bias))
	      (l-  (1- (length s))))
	  (append
	   (list (tx-token (substring s 0 1) p+ (+ p+ 1)))
	   (tx-get-expressions1 s (- p+ 1) t)
	   (list (tx-token (substring s l-) 
			   (+ p+ l-)
			   (+ p+ l- 1)
			   ))))
	;;
	)
       (t
	(tx-get-expressions1 s (+ (- p 1) bias))
	)))))

(defun tx-get-expressions1 (in &optional bias downlist)
  (let ((s0 (buffer-string))
	(p0 (point)))
    (erase-buffer)
    (let ((r (tx-get-expressions01 in bias downlist)))
      (erase-buffer)
      (insert s0)
      (goto-char p0)
      r)))

(defun tx-get-expressions01 (in &optional bias downlist)
  (insert in)
  (goto-char (point-min))
  (when downlist
    (down-list 1))
  (let ((result (list)))
    (condition-case err
	(while (not (eobp))
	  (let ((r0 (tx-get-expressions00 (or bias 0))))
	    (if (equal (car (last r0)) (car (last result)))
		(goto-char (point-max))
	      (setq result (append result r0))
	      )))
      (error result))
    result
    ))

(defun tx-get-expressions0 (in &optional bias downlist)
  (with-temp-buffer
    (c-mode)
    (tx-get-expressions01 in bias downlist)
    ))

(defun tx-get-expressions (in &optional bias)
  (tx-get-expressions0 in bias))

(require 'which-func)
(defun tx-get-expressions-here ()
  (let ((func (condition-case nil
		  (which-function)
		(error nil)))	)
    (when func
      (let ((range (save-excursion (beginning-of-defun)
				   (let ((b (point)))
				     (let ((e (when (re-search-forward "{" nil t)
						(end-of-defun)
						(point))))
				       (if e
					   (list b e)
					 nil))))))
	(if range
	    (if (and (<= (car range) (point))
		     (<= (point) (cadr range)))
		(tx-get-expressions (buffer-substring-no-properties (car range) (cadr range)) (car range))
	      nil))))))