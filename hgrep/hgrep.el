(defconst hgrep "/home/yamato/var/srpmix/hgrep/hgrep")

(defconst hgrep-dist-default "rhel5su4")
(defvar hgrep-dist-history nil)

(defun dist-hgrep-all-dist/update ()
  (let ((candidates (delete "." (delete ".." (directory-files "/srv/sources/dists/"))))
	(results (list)))
    (while candidates
      (when (file-directory-p (format "/srv/sources/dists/%s/plugins/hyperestraier/idx" 
				      (car candidates)))
	(setq results (cons (car candidates) results)))
      (setq candidates (cdr candidates)))
    results))


(defun dist-hgrep (dist/update phase)
  (interactive (list
		(let ((dists/updates (dist-hgrep-all-dist/update)))
		  (completing-read (format "Distribution/update (default: %s): " hgrep-default-dist) 
				   dists/updates
				   nil
				   t
				   nil
				   'hgrep-dist-history
				   hgrep-dist-default))
		(read-from-minibuffer "Phase: ")
		))
  (grep (format "%s %s '%s'" 
		hgrep 
		dist/update
		phase)))
(provide 'hgrep)