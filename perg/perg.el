(defvar perg-database nil)
(defun  perg-set-database (file)
  (interactive "fes-src-xgettext data base file: ")
  (setq perg-database file)
  perg-database)

(defvar perg-log-lines nil)
(defun perg (file pattern)
  (interactive (list
		(if current-prefix-arg
		    (call-interactively 'perg-set-database)
		  perg-database )
		(read-from-minibuffer "Log line: " nil
				      nil nil 'perg-log-lines
				      (buffer-substring (line-beginning-position)
							(line-end-position)))))
  (grep (format "%sperg %s '%s'" 
		(if (string-match "\\(.*\\)/plugins.*" file)
		    (format "cd %s; " (expand-file-name (match-string 1 file)))
		  "")
		file pattern)))
(provide 'perg)