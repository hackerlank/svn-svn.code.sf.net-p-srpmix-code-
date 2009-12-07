(defun dive-find-file-install-action ()
  (add-hook 'find-file-hook 'dive-find-file-do))
(defun dive-find-file-uninstall-action ()
  (remove-hook 'find-file-hook 'dive-find-file-do))

(defvar dive-sources-buffer nil)
(defun dive-find-file-do ()
  (when (string-match ".*/srv/sources/.*/pre-build/.*" (buffer-file-name))
    (set (make-local-variable 'dive-sources-buffer) t)))

(dive-find-file-install-action)

(provide 'dive-find-file-action)