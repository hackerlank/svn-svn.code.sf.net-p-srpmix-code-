;; (lsync ((name line string)...) :message "XXX")

(lsync-show '(lsync (("/tmp/inspect/mask01" 10) 
		     ("/tmp/inspect/mask02" 12)
		     ("/tmp/inspect/mask03" 190)) "TEST"))

(defvar lsync-kill-slot nil)
(defun lsync-kill-save ()
  (interactive)
  (setq lsync-kill-slot
	(list (buffer-file-name)
	      (current-line)
	      (buffer-substring-no-properties (line-beginning-position)
					      (line-end-position)))))
(defun lsync-yank ()
  (interactive)
  (print lsync-kill-slot (current-buffer)))
  
(define-key global-map [(hyper ?w)] 'lsync-kill-save)
(define-key global-map [(hyper ?y)] 'lsync-yank)

(defmacro lsync (lines annot)
  `(lsync-show '(lsync ,lines ,annot)))

(defun lsync-show (spec)
  (save-excursion
    (let ((ovs (mapcar (lambda (s)
			 (let ((name (car s))
			       (line (cadr s))
			       (string (caddr s)))
			   (let ((b (find-file-noselect name)))
			     (with-current-buffer b
			       (unless (get-buffer-window-list b)
				 (split-window)
				 (pop-to-buffer b))
			       (goto-line line)
			       (let ((o (make-overlay (line-beginning-position)
						      (line-end-position))))
				 (overlay-put o 'face 'highlight)
				 o)
			       ))))
		       (cadr spec))))
      (let ((m (caddr spec)))
	(when m
	  (message "lsync: %s" m)))
      (sit-for 10000)
      (mapc '(lambda (o) (goto-char (overlay-start o)) (recenter)) ovs)
      (mapc 'delete-overlay ovs))))
    
