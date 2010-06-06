(defconst flserver t)

(defvar   flserver-dir nil)
(defvar   flserver-plugins-dir nil)
(defvar   flserver-modes-dir nil)

(defun flserver-extend-load-path ()
  (let ((file (symbol-file 'flserver)))
    (setq flserver-dir (concat 
			(file-name-as-directory (file-name-directory file))
			"flserver"))
    (setq flserver-plugins-dir (concat 
				(file-name-as-directory flserver-dir)
				"plugins"))
    (setq flserver-modes-dir (concat 
			      (file-name-as-directory flserver-dir)
			      "modes"))
    (setq load-path (append 
		     (list flserver-modes-dir
			   flserver-plugins-dir
			   flserver-dir)
		     load-path))))

(defun flserver-list-el (dir filter-regex sort-regex)
  (if (file-directory-p dir)
      (mapcar
       #'cdr
       (sort (mapcar
	      (lambda (el)
		(string-match sort-regex el)
		(cons (match-string 2 el) (intern (match-string 1 el))))
	      (directory-files dir nil filter-regex t)
	      )
	     (lambda (a b)
	       (string< (car a) (car b)))))
    nil))

(defun flserver-load-plugin-decls ()
  (mapc
   (lambda (entry)
     (message "+%s" entry)
     (require entry)
     )
   (flserver-list-el flserver-plugins-dir
		     ".*-decl.el$"
		     "\\(\\(.*\\)-decl\\).el$")))

(defun flserver-load-plugin-mains ()
  (mapc
   #'require
   (flserver-list-el flserver-plugins-dir
		     ".*-main.el$"
		     "\\(\\(.*\\)-main\\).el$"))
  )


(provide 'flserver-boot)
