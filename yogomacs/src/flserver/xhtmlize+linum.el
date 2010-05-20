(require 'linum)
(require 'xhtmlize)

(defvar xhtmlize-linum-web-dir nil)
;(defvar xhtmlize-linum-web-url nil)
(defvar xhtmlize-linum-apr-url nil)

(defun xhtmlize-linum-acceptable-p (o)
  (if (overlay-get o 'linum-str) t nil))
(defun xhtmlize-linum-prepare  (o)
  (let ((s (overlay-get o 'linum-str)))
    (put-text-property 0 (length s) 'face 'linum s)
    s))
(defun xhtmlize-linum-make-id  (o)
  (let ((str (overlay-get o 'linum-str)))
    (format "linum:%s" 
	    (car (split-string str))
	    )))
(defun xhtmlize-linum-make-href (o)
  (when (and xhtmlize-linum-api-url
	     xhtmlize-linum-web-dir)
    (let ((file (buffer-file-name (overlay-buffer o))))
      (concat ;xhtmlize-linum-api-url 
	      ;"/"
	      ;"browse.cgi"
	      ;"?path="
	      ;(substring file (1+ (length xhtmlize-linum-web-dir)))
	      ;"&display=font-lock"
	      "#"
	      (xhtmlize-linum-make-id o)))))

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
	 (set-window-margins (win width)))
    (linum-update-window nil)))


(provide 'xhtmlize+linum)
