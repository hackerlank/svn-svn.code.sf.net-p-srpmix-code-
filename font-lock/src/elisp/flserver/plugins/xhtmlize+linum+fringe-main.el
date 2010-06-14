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


;;
;; TODO: before
;; <span style="color: red;float: right;">****************</span>
;;
;; (define-xhtmlize-pre-linum-handler 'xhtmlize-linum-lfringe-render-direct)
;; (defun xhtmlize-linum-lfringe-render-direct (line point insert-method face-map engine)
;;   (let ((text  " ")
;; 	(id (concat "f:L"))
;; 	(href nil)
;; 	(fstruct-list (xhtmlize-linum-fringe-fstruct-list-cache face-map))
;; 	)
;;     (funcall insert-method
;; 	     text
;; 	     id
;; 	     href
;; 	     fstruct-list
;; 	     engine)))

(define-xhtmlize-post-linum-handler 'xhtmlize-linum-rfringe-render-direct)
(defun xhtmlize-linum-rfringe-render-direct (line point insert-method face-map engine)
  (let ((text  " ")
	(id (concat "f:R;"
		    "P:" (number-to-string point)
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