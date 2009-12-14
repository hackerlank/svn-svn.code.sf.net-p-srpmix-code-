(require 'assoc)
(require 'regexp-opt)
(defconst dive-tokenize-keywords-regex
  (concat 
   "^" 
   (regexp-opt 
    '(
      "auto" "break" "case" "char" "const" "continue"		
      "default" "do" "double" "else" "enum" "extern" "float"			
      "for" "goto" "if" "int" "long" "register" "return"		
      "short" "signed" "sizeof" "static" "struct" "switch" 
      "typedef" "union" "unsigned" "void" "volatile" "while"
      ))
   "$"))

(defun dive-tokenize-is-list (s)
  (memq (string-to-char s) '(?\( ?\{ ?\[)))

(defun dive-tokenize-is-symbol (s)
  (string-match "^\\_<.*\\_>$" s))
(defun dive-tokenize-is-string (s)
  (string-match "^\".*\"$" s))
(defun dive-tokenize-is-number (s)
  (string-match "^-?[0-9]+$" s))
(defun dive-tokenize-rest (s)
  t)

(defun dive-tokenize-is-keyword (s)
  (string-match dive-tokenize-keywords-regex s)
  )

(defun dive-tokenize-calibrate-pos ()
  (forward-sexp 1)
  (backward-sexp 1))

(defun dive-tokenize-token-type (token)
  (aref token 3))
(defun dive-tokenize-token-expression (token)
  (aref token 0))
(defun dive-tokenize-token-start (token)
  (aref token 1))
(defun dive-tokenize-token-end (token)
  (aref token 2))

(defun dive-tokenize-token-aget (token key)
  (aget (aref token 4) key))

(defun dive-tokenize-token-aput (token key value)
  ;; TODO
  (aset token 4 (cons (cons key value) (aref token 4))))

(defun dive-tokenize-make-token (str b e &optional type)
  (vector 
   (cond
    ((eq type 'keyword) 
     (intern str))
    ((or (eq type 'open)
	 (eq type 'close))
     (string-to-char str)
     )
    (t
     str))
   b e type
   (list)
   ))

(defun dive-tokenize-get-expressions00 (bias)
  (dive-tokenize-calibrate-pos)
  (let ((p (point)))
    (forward-sexp 1)
    (let ((s (buffer-substring-no-properties p (point))))
      (cond
;       ((eobp)
;	(list (dive-tokenize-make-token s
;				   (+ p bias)
;				   (+ (point) bias))))
       ((dive-tokenize-is-list s)
	(let ((p+ (+ p bias))
	      (l-  (1- (length s))))
	  (append
	   (list (dive-tokenize-make-token (substring s 0 1) p+ (+ p+ 1) 'open))
	   (dive-tokenize-get-expressions1 s (- p+ 1) t)
	   (list (dive-tokenize-make-token (substring s l-) 
				      (+ p+ l-)
				      (+ p+ l- 1)
				      'close))))
	;;
	)
       ((dive-tokenize-is-symbol s)
	(list (dive-tokenize-make-token s
				   (+ p bias)
				   (+ (point) bias)
				   (if (dive-tokenize-is-keyword s) 'keyword 'identifier)
				   )))
       ((or (dive-tokenize-is-string s) (dive-tokenize-is-number s))
	(list (dive-tokenize-make-token s
				   (+ p bias)
				   (+ (point) bias))))
       ((dive-tokenize-rest s)
	(dive-tokenize-get-expressions1 s (+ (- p 1) bias))
	)))))

(defun dive-tokenize-get-expressions1 (in &optional bias downlist)
  (let ((s0 (buffer-string))
	(p0 (point)))
    (erase-buffer)
    (let ((r (dive-tokenize-get-expressions01 in bias downlist)))
      (erase-buffer)
      (insert s0)
      (goto-char p0)
      r)))

(defun dive-tokenize-get-expressions01 (in &optional bias downlist)
  (insert in)
  (goto-char (point-min))
  (when downlist
    (down-list 1))
  (let ((result (list)))
    (condition-case err
	(while (not (eobp))
	  (let ((r0 (dive-tokenize-get-expressions00 (or bias 0))))
	    (if (equal (car (last r0)) (car (last result)))
		(goto-char (point-max))
	      (setq result (append result r0))
	      )))
      (error result))
    result
    ))

(defun dive-tokenize-get-expressions0 (in &optional bias downlist)
  (with-temp-buffer
    (c-mode)
    (dive-tokenize-get-expressions01 in bias downlist)
    ))

(defun dive-tokenize-get-expressions (in &optional bias)
  (dive-tokenize-get-expressions0 in bias))

;; ENTRY POINT
(require 'which-func)

(defun dive-tokenize-get-expressions-here ()
  (let ((func (condition-case nil
		  (which-function)
		(error nil)))	)
    (when func
      (let ((range (save-excursion 
		     (condition-case nil
			 (beginning-of-defun)
		       (error nil))
		     (let ((b (point)))
		       (let ((e (when (re-search-forward "{" nil t)
				  (condition-case nil
				      (progn
					(end-of-defun)
					(point))
				    (error nil)))))
					
			 (if e
			     (list b e)
			   nil))))))
	(if range
	    (if (and (<= (car range) (point))
		     (<= (point) (cadr range)))
		(dive-tokenize-get-expressions (buffer-substring-no-properties 
						(car range)
						(cadr range)) 
					       (car range))
	      nil))))))

(provide 'dive-tokenize)