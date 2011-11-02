(defun c-show-conditional-context ()
  (interactive)
  (let ((context (c-build-conditional-context)))
    (message "%s" (c-render-conditional-context context))))

(defun c-render-conditional-context (context)
  (if context
      (let* ((d 4)
	      (indent (* d -1))
	      (here `(">>HERE<<" :point ,(point) :line ,(line-number-at-pos))))
	 (mapconcat 'identity (mapcar 
			       (lambda (c)
				 (format "%s"
					 (let ((elt (car c)))
					   (cond
					    ((string-match "#[ \t]*if" elt)
					     (setq indent (+ indent d))
					     (concat (make-string indent ?\ ) elt))
					    ((string-match "#[ \t]*elif" elt)
					     (concat (make-string indent ?\ ) elt))
					    ((string-match "#[ \t]*else" elt)
					     (concat (make-string indent ?\ ) elt))
					    (t
					     (setq indent (+ indent d))
					     (concat (make-string indent ?\ ) elt))))))
			       (reverse (cons here (reverse context))))
		    "\n"))
    "<top>"))

(defun c-build-conditional-context ()
  (save-excursion
    (let ((context ()))
      (condition-case nil
	  (while t
	    (c-up-conditional-with-else 1)
	    ;; push
	    (setq context 
		  (cons (let ((p (line-beginning-position)))
			  (list (buffer-substring p (line-end-position))
				:point p
				:line (line-number-at-pos)
				))
			context)))
	(error nil))
      context)))

(defun c-conditional-context-eldoc-function ()
  (c-render-conditional-context
   (c-build-conditional-context)))

(add-hook 'c-mode-hook
	  (lambda ()
	    (set (make-local-variable 'eldoc-documentation-function)
		  #'c-conditional-context-eldoc-function)
	    (turn-on-eldoc-mode)))

(provide 'cc-eldoc)