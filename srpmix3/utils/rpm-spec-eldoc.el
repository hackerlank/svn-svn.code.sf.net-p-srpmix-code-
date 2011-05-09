;; /usr/bin/bugzilla is expected to be installed.
(require 'thingatpt)

(add-hook 'rpm-spec-mode-hook 'rpm-spec-eldoc-install)

(defvar rpm-spec-eldoc-hash (make-hash-table :test 'eq))
(defun rpm-spec-eldoc-install ()
  (set (make-local-variable 'eldoc-documentation-function)
       #'rpm-spec-eldoc-function))

(defun rpm-spec-eldoc-function ()
  (when (save-excursion (re-search-backward "^%changelog" nil t))
    (let ((num (thing-at-point 'symbol)))
      (cond
       ((string-match "[0-9]\\{5,\\}" num)
	(setq num (string-to-number num))
	(or (gethash num rpm-spec-eldoc-hash)
	    (let ((r (shell-command-to-string (format "/usr/bin/bugzilla query -b %d --outputformat='%%{bug_id}: %%{short_desc}'"
					 num))))
	      (if (equal r "")
		  (setq r "bz: cannot find entry")
		(setq r (substring r 0 (1- (length r)))))
	      (puthash num r rpm-spec-eldoc-hash)
	      r)))
       (t
	"")))))

(provide 'rpm-spec-eldoc)
