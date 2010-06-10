(require 'linum)
(require 'xhtmlize)
(require 'xhtmlize+linum-decl)


(defvar xhtmlize-linum-bol-handler (list))
(defun define-xhtmlize-linum-bol-handler (render-direct)
  (setq xhtmlize-linum-bol-handler
	(cons `(render-direct . ,render-direct)
	      xhtmlize-linum-bol-handler)))



(defun xhtmlize-linum-acceptable-p (o)
  (if (overlay-get o 'linum-str) t nil))

(defvar xhtmlize-linum-fstruct-list-cache nil)
(defun xhtmlize-linum-fstruct-list-cache (face-map)
  (if xhtmlize-linum-fstruct-list-cache
      xhtmlize-linum-fstruct-list-cache
    (setq xhtmlize-linum-fstruct-list-cache 
	  (mapcar (lambda (f) (gethash f face-map)) '(linum)))
    xhtmlize-linum-fstruct-list-cache))

(defun xhtmlize-linum-render-direct (o insert-method face-map engine)
  (let* ((str0 (overlay-get o 'linum-str))
	 (str (substring-no-properties str0))
	 (line-str (car (split-string str)))
	 (point (point))
	 (id (concat "L:" line-str))
	 (href (concat "#" id)) ; TODO: "L:" is needed?
	 (fstruct-list (xhtmlize-linum-fstruct-list-cache face-map)))
    (funcall insert-method 
	     str
	     id
	     href
	     fstruct-list
	     engine)
    (when xhtmlize-linum-bol-handler
      (let ((line (string-to-number line-str)))
	(mapc
	 (lambda (handler)
	   (let ((render-direct (cdr (assq 'render-direct xhtmlize-linum-bol-handler))))
	     (when render-direct
	       (funcall render-direct line point insert-method face-map engine)
	       )
	     ))
	 xhtmlize-linum-bol-handler)))))

(defun xhtmlize-linum-prepare  (o)
  (let ((str (overlay-get o 'linum-str)))
    (put-text-property 0 (length str) 'face 'linum str)
    str))
(defun xhtmlize-linum-make-id  (o)
  (let ((str (overlay-get o 'linum-str)))
    (concat "L:" (car (split-string str)))))
(defun xhtmlize-linum-make-href (o)
  (let ((file (buffer-file-name (overlay-buffer o))))
    (concat "#" (xhtmlize-linum-make-id o))))

(define-xhtmlize-width0-overlay-handler
  'xhtmlize-linum-acceptable-p
  'xhtmlize-linum-render-direct
  'xhtmlize-linum-prepare
  'xhtmlize-linum-make-id
  'xhtmlize-linum-make-href)

(add-hook 'xhtmlize-before-hook
          'xhtmlize-linum-update-buffer)

(defun xhtmlize-linum-update-buffer ()
  (flet ((window-start (win) (point-min))
         (window-end (win &optional update) (point-max))
         (set-window-margins (win width &rest ignore)))
    (linum-update-window nil)))

(xhtmlize-add-builtin-faces 'linum)
(xhtmlize-add-builtin-faces 'highlight)


(provide 'xhtmlize+linum-main)
