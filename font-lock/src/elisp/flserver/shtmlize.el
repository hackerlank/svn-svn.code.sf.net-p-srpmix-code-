(require 'xhtmlize)
(require 'shtmlize-engine)

(defun shtmlize-file (file &optional target)
  (interactive (list (read-file-name
		      "HTML-ize file: "
		      nil nil nil (and (buffer-file-name)
				       (file-name-nondirectory
					(buffer-file-name))))))
  (xhtmlize-file file target 'shtmlize))

(defun shtmlize-buffer (&optional buffer)
  (interactive)
  (let ((shtmlbuf (xhtmlize-buffer buffer 'shtmlize)))
    (when (interactive-p)
      (switch-to-buffer shtmlbuf))
    shtmlbuf))

(provide 'shtmlize)