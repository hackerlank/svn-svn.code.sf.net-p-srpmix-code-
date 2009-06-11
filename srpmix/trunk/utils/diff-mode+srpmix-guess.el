(require 'diff-mode)
(defadvice diff-find-file-name (around srpmix-guess activate)
  (let ((default-directory (if (string-match "/archives/$" default-directory)
			       (file-name-as-directory
				(concat (file-name-directory 
					 (directory-file-name default-directory))
					"pre-build"))
			     default-directory)))
    ad-do-it))

(provide 'diff-mode+srpmix-guess)