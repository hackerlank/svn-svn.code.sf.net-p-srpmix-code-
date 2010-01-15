(defconst hgrep "/home/yamato/var/srpmix/hgrep/hgrep")

(defconst hgrep-dist-default "rhel5su4")
(defvar hgrep-dist-history nil)

(defun dist-hgrep-all-dists/updates ()
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
		(let ((dists/updates (dist-hgrep-all-dists/updates)))
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
(defalias 'hgrep-dist 'dist-hgrep)

(defvar hgrep-pkg-history nil)

(defun dist-hgrep-all-pkgs (dist/update)
  (let ((candidates-A (delete "." (delete ".." (directory-files (format "/srv/sources/dists/%s/packages" dist/update)))))
	(results (list)))
    (while candidates-A
      (when (file-directory-p (format "/srv/sources/dists/%s/packages/%s" dist/update (car candidates-A)))
	(let* ((d-A (format "/srv/sources/dists/%s/packages/%s" dist/update (car candidates-A)))
	       (candidates (delete "." (delete ".." (directory-files d-A)))))
	  (while candidates
	    (when (file-directory-p (format "%s/%s/plugins/hyperestraier/idx" d-A (car candidates)))
	      (setq results (cons (car candidates) results)))
	    (setq candidates (cdr candidates)))))
      (setq candidates-A (cdr candidates-A)))
    results))

(defun hgrep-read-pkgs (prompt dist/update)
  (let ((r (list))
	(r0 nil)
	(candidates (dist-hgrep-all-pkgs dist/update)))
    (while (not (equal (setq r0 (completing-read prompt candidates nil t nil 'hgrep-pkg-history)) ""))
      (when (file-directory-p (format "/srv/sources/dists/%s/packages/%s/%s/plugins/hyperestraier/idx" 
				      dist/update
				      (substring r0 0 1)
				      r0))
	(setq r (cons r0 r))))
    (reverse r)))

(defun pkg-hgrep (dist/update phase &rest pkgs)
  (interactive (let* ((dists/updates (dist-hgrep-all-dists/updates))
		      (dist/update (completing-read (format "Distribution/update (default: %s): " hgrep-default-dist) 
						    dists/updates
						    nil
						    t
						    nil
						    'hgrep-dist-history
						    hgrep-dist-default))
		      (pkgs 		  (hgrep-read-pkgs "Package: " dist/update))
		      (phase (read-from-minibuffer "Phase: ")))
		 `(
		   ,dist/update
		   ,phase
		   ,@pkgs
		  )))
  
    (grep (format "%s %s %s '%s'" 
		hgrep 
		dist/update
		(mapconcat 'identity pkgs " ")
		phase)))

(defalias 'hgrep-pkg 'pkg-hgrep)

(provide 'hgrep)