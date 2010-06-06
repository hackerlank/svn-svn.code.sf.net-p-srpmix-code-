(defconst flserver t)

(defun flserver-extend-load-path ()
  (let* ((file (symbol-file 'flserver))
	 (flserver-dir (concat 
			(file-name-as-directory (file-name-directory file))
			"flserver"))
	 ;;
	 (plugins-dir (concat 
		       (file-name-as-directory flserver-dir)
		       "plugins"))
	 (modes-dir (concat 
		     (file-name-as-directory flserver-dir)
		     "modes"))
	 )
    (setq load-path (append 
		     (list modes-dir
			   plugins-dir
			   flserver-dir)
		     load-path))))

(defun flserver-load-plugin-decls ()
  ;; TODO
  ;; Func for load plugins(decl and main)
  )

(defun flserver-load-plugin-mains ()
  ;; TODO
  ;; Func for load plugins(decl and main)
  )

(provide 'flserver-boot)
