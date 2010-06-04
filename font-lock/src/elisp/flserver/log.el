(defvar log-file nil)
(defun log-set-file (file)
  (setq log-file file))

(defvar log-ident "emacs")
(defun log-set-identity (ident)
  (setq log-ident ident))

(defvar log-buffer nil)
(defun log-string (str)
  (unless log-buffer
    (setq log-buffer (if log-file
			 (let ((b (find-file-noselect log-file)))
			   (with-current-buffer b
			     (set (make-local-variable 'make-backup-files) nil))
			   b)
		       (get-buffer-create "*LOG*"))))
  (with-current-buffer log-buffer
    (goto-char (point-max))
    ;; Jun  4 14:21:44 dhcp-193-209 abrtd: Init complete, entering main loop
    (insert (format "%s %s %s: %s\n" 
		    (current-time-string) mail-host-address log-ident str))
    (when log-file
      (save-buffer))))

(defun log-format (fmt &rest args)
  (let ((str (apply #'format fmt args)))
    (log-string str)))

(defmacro with-log-string (key str &rest body)
  `(progn
     (log-format "%s-start %s" ,key ,str)
     ,@body
     (log-format "%s-end %s" ,key ,str)))

(provide 'log)
