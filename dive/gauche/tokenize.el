(defun can-go-down   (s)
  (memq (string-to-char s) '(?\( ?\{ ?\[))  
  )

(defun calibrate-pos ()
  (forward-sexp 1)
  (backward-sexp 1))

(defun token (str b e)
  (vector str b e))

(defun get-expressions00 (bias)
  (calibrate-pos)
  (let ((p (point)))
    (forward-sexp 1)
    (let ((s (buffer-substring-no-properties p (point))))
      (cond
       ((eobp)
	(list (token s
		     (+ p bias)
		     (+ (point) bias))))
       ((can-go-down s)
;;	(get-expressions0 (substring s 1 -1) (+ (+ (- p 1) 1) bias) t)
	(append
	 (list (token (substring s 0 1)
		      (+ p bias)
		      (+ (+ p bias) 1)))
	 (get-expressions0 s (+ (- p 1) bias) t)
	 (list (token (substring s (1- (length s))) 
		      (+ (+ p bias) (1- (length s)))
		      (+ (+ p bias) (1- (length s)) 1)
		      )))
	;;
	)
       (t
	(get-expressions0 s (+ (- p 1) bias))
	)))))

(defun get-expressions0 (in &optional bias downlist)
  (with-temp-buffer
    (insert in)
    (goto-char (point-min))
    (when downlist
      (down-list 1))
    (let ((result (list)))
      (condition-case err
	  (while (not (eobp))
	    (let ((r0 (get-expressions00 (or bias 0))))
	      (if (equal (car (reverse r0)) (car (reverse result)))
		  (goto-char (point-max))
		(setq result (append result r0))
		)))
	(error result))
      result
      )))

(defun get-expressions (in &optional bias)
  (get-expressionos0 in bias))
	