(require 'xhtmlize+linum-main)
(require 'xhtmlize+linum+fringe-decl)

;; TODO: define macro.
(defvar xhtmlize-linum-fringe-fstruct-list-cache nil)
(defun xhtmlize-linum-fringe-fstruct-list-cache (face-map)
  (if xhtmlize-linum-fringe-fstruct-list-cache
      xhtmlize-linum-fringe-fstruct-list-cache
    (setq xhtmlize-linum-fringe-fstruct-list-cache 
	  (mapcar (lambda (f) (gethash f face-map)) '(fringe)))
    xhtmlize-linum-fringe-fstruct-list-cache))


(define-xhtmlize-linum-bol-handler 'xhtmlize-linum-fringe-redner-direct)
(defun xhtmlize-linum-fringe-redner-direct (line point insert-method face-map engine)
  (let ((text  " ")
	(id (concat "P:" (number-to-string point)
		    ";"
		    "L:" (number-to-string line)
		    ))
	(href nil)
	(fstruct-list (xhtmlize-linum-fringe-fstruct-list-cache face-map))
	)
    (funcall insert-method
	     text
	     id
	     href
	     fstruct-list
	     engine)))

(xhtmlize-add-builtin-faces 'fringe)

(provide 'xhtmlize+linum+fringe-main)