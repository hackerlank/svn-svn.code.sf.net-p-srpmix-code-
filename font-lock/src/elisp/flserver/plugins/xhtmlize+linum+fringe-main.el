(eval-when-compile 
  (require 'cssize))
(require 'xhtmlize+linum-main)
(require 'xhtmlize+linum+fringe-decl)

;; TODO: define macro.
(defvar xhtmlize-linum-lfringe-fstruct-list-cache nil)
(defsubst xhtmlize-linum-lfringe-fstruct-list-cache (face-map)
  (if xhtmlize-linum-lfringe-fstruct-list-cache
      xhtmlize-linum-lfringe-fstruct-list-cache
    (setq xhtmlize-linum-lfringe-fstruct-list-cache 
	  (mapcar (lambda (f) (gethash f face-map)) '(lfringe)))
    xhtmlize-linum-lfringe-fstruct-list-cache))
(defvar xhtmlize-linum-rfringe-fstruct-list-cache nil)
(defsubst xhtmlize-linum-rfringe-fstruct-list-cache (face-map)
  (if xhtmlize-linum-rfringe-fstruct-list-cache
      xhtmlize-linum-rfringe-fstruct-list-cache
    (setq xhtmlize-linum-rfringe-fstruct-list-cache 
	  (mapcar (lambda (f) (gethash f face-map)) '(rfringe)))
    xhtmlize-linum-rfringe-fstruct-list-cache))

(define-xhtmlize-post-linum-handler 'xhtmlize-linum-rfringe-render-direct)
(defun xhtmlize-linum-rfringe-render-direct (line-str point insert-method face-map engine)
  (let* ((text  " ")
	 (lid (concat "l/P:" (number-to-string point) "/L:" line-str))
	 (rid (concat "r/L:" line-str))
	 (lfstruct-list (xhtmlize-linum-lfringe-fstruct-list-cache face-map))
	 (rfstruct-list (xhtmlize-linum-rfringe-fstruct-list-cache face-map))
	 )
    (funcall insert-method
	     text
	     lid
	     nil
	     lfstruct-list
	     engine)
    (funcall insert-method
	     text
	     rid
	     nil
	     rfstruct-list
	     engine)
    ))

(defface lfringe '((t :inherit fringe))
  "Dummy face for left fringe in html")
(define-cssize-pseudo-face-attr-table rfringe ((float . right)))
(xhtmlize-add-builtin-faces 'lfringe)

(defface rfringe '((t :inherit fringe))
  "Dummy face for right fringe in html")
(define-cssize-pseudo-face-attr-table lfringe ((float . left)))
(xhtmlize-add-builtin-faces 'rfringe)
  
(provide 'xhtmlize+linum+fringe-main)