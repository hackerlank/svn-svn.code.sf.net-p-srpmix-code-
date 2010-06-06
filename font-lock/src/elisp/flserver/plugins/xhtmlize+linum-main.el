(require 'linum)
(require 'xhtmlize)
(require 'xhtmlize+linum-decl)

(defun xhtmlize-linum-acceptable-p (o)
  (if (overlay-get o 'linum-str) t nil))
(defun xhtmlize-linum-prepare  (o)
  (let ((s (overlay-get o 'linum-str)))
    (put-text-property 0 (length s) 'face 'linum s)
    s))
(defun xhtmlize-linum-make-id  (o)
  (let ((str (overlay-get o 'linum-str)))
    (concat "L:" (car (split-string str)))))

(defun xhtmlize-linum-make-href (o)
  (let ((file (buffer-file-name (overlay-buffer o))))
    (concat "#" (xhtmlize-linum-make-id o))))

(xhtmlize-register-zero-overlay-handler
 'xhtmlize-linum-acceptable-p
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

(provide 'xhtmlize+linum-main)
