(add-hook 'rpm-spec-mode-hook
	  (lambda ()
	    (define-key rpm-spec-mode-map "\C-c\C-j" 'rpm-jump-to-patch-file)))

(defun rpm-jump-to-patch-file ()
  (interactive)
  (let ((file (save-excursion
		(beginning-of-line)
		(cond
		 ((looking-at "Patch[0-9]+:\\s-*\\(.*\\)")
		  (match-string 1))
		 ((looking-at "%patch\\([0-9]+\\)")
		  (let ((pnum (match-string 1)))
		    (goto-char (point-min))
		    (if (re-search-forward (format "Patch%s:" pnum)
					   nil
					   t)
			(rpm-jump-to-patch-file)
		      nil)))
		 (t
		  nil)))))
    (if file
	(srpmix-find-file-in-archives file)
      (error "Cannot patch line"))))

(defun srpmix-find-file-in-archives (file)
  (find-file (format "./%s/%s" "archives" file)))

(provide 'rpm-spec-mode+srpmix-jump)
  