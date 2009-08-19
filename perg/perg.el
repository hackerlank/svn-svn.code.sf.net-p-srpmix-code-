(defvar perg-database nil)
(defun  perg-set-database (file)
  (interactive "fes-src-xgettext data base file: ")
  (setq perg-database file)
  perg-database)

(defvar perg-log-lines nil)
(defun perg (file pattern)
  (interactive (list
		(or perg-database
		    (call-interactively 'perg-set-database))
		(read-from-minibuffer "Log line: " nil
				      nil nil 'perg-log-lines
				      (buffer-substring (line-beginning-position)
							(line-end-position)))))
  (grep (format "perg %s '%s'" file pattern)))
(provide 'perg)