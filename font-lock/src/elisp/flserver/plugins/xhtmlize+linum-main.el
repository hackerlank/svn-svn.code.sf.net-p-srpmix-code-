(require 'linum)
(require 'xhtmlize)
(require 'xhtmlize+linum-decl)


(defvar xhtmlize-pre-linum-handlers (list))
(defun define-xhtmlize-pre-linum-handler (render-direct)
  (setq xhtmlize-pre-linum-handlers
	(cons `((render-direct . ,render-direct))
	      xhtmlize-pre-linum-handlers)))

(defvar xhtmlize-post-linum-handlers (list))
(defun define-xhtmlize-post-linum-handler (render-direct)
  (setq xhtmlize-post-linum-handlers
	(cons `((render-direct . ,render-direct))
	      xhtmlize-post-linum-handlers)))




(defun xhtmlize-linum-acceptable-p (o)
  (overlay-get o 'linum-str))

(defvar xhtmlize-linum-fstruct-list-cache nil)
(defun xhtmlize-linum-fstruct-list-cache (face-map)
  (if xhtmlize-linum-fstruct-list-cache
      xhtmlize-linum-fstruct-list-cache
    (setq xhtmlize-linum-fstruct-list-cache 
	  (mapcar (lambda (f) (gethash f face-map)) '(linum)))
    xhtmlize-linum-fstruct-list-cache))

(defsubst xhtmlize-linum-drop-whitespace (str)
  (let ((i 0))
    (while (eq (aref str i) ?\ )
      (setq i (1+ i)))
    (substring-no-properties str i)))

(defun xhtmlize-linum-render-direct (o insert-method face-map engine)
  (let* ((str0 (overlay-get o 'linum-str))
	 (str (substring-no-properties str0))
	 (line-str (car (split-string str)))
	 ;(line-str (xhtmlize-linum-drop-whitespace (overlay-get o 'linum-str)))
	 ;(line (string-to-number line-str))
	 ;(line (car (read-from-string (overlay-get o 'linum-str))))
	 ;(line-str (number-to-string line))
	 (point (point))
	 (id (concat "N:" line-str))
	 (href (concat "#N:" id)) ; TODO: "L:" is needed?
	 (fstruct-list (xhtmlize-linum-fstruct-list-cache face-map))
	 ;(line (string-to-number line-str))
	 )

    (when xhtmlize-pre-linum-handlers
      (mapc
       (lambda (handler)
	 (let ((render-direct (cdr (assq 'render-direct handler))))
	   (when render-direct
	     (funcall render-direct line-str point insert-method face-map engine)
	     )
	   ))
       xhtmlize-pre-linum-handlers))
    (funcall insert-method 
	     str
	     id
	     href
	     fstruct-list
	     engine)
    (mapc
       (lambda (handler)
	 (let ((render-direct (cdr (assq 'render-direct handler))))
	   (when render-direct
	     (funcall render-direct line-str point insert-method face-map engine)
	     )
	   ))
       xhtmlize-post-linum-handlers)))

(defun xhtmlize-linum-prepare  (o)
  (let ((str (overlay-get o 'linum-str)))
    (put-text-property 0 (length str) 'face 'linum str)
    str))
(defun xhtmlize-linum-make-id  (o)
  (let ((str (substring-no-properties (overlay-get o 'linum-str))))
    (car (split-string str))))
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
(define-cssize-pseudo-face-attr-table linum ((float . left)))

(xhtmlize-add-builtin-faces 'highlight)


(provide 'xhtmlize+linum-main)
