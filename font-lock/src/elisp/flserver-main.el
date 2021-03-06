(require 'flserver-decl)

;;
;; Enable logging
;;
(require 'log)
(log-set-identity flserver-server-name)
(setq message-log-max flserver-log-max)
(log-string "initializing...")


;;
;; Disable interactive features
;;
(setq enable-local-variables nil
      enable-local-eval nil
      local-enable-local-variables nil)
(set 'font-lock-support-mode nil)
(remove-hook 'find-file-hook 'vc-find-file-hook)

;;
;; Don't create backup file
;;
(setq make-backup-files nil)

;;
;; Server setup
;;
(require 'server)
(when flserver-server-name
  (setq server-name flserver-server-name))
(setq server-raise-frame nil)

;;
;; Load libraries
;;
(require 'xhtmlize)
(require 'xhtmlize-engine)
(require 'cssize)

(require 'shtmlize)

(with-log-string "loading plugins" ""
		 (flserver-load-plugin-mains))

;;
;; Extra modes
;;
;; ...

;;
;; Idle logout
;;
(defvar flserver-timestamp nil)
(defun flserver-timtout-p ()
  (let ((delta (nth 1 (time-subtract (current-time) 
				     flserver-timestamp
				     ))))
    (> delta
       flserver-idle-timeout)))
(defun flserver-touch ()
  (setq flserver-timestamp (current-time)))

;;
;; Entry point for client
;;
(defun gc-buffers (bl-old)
  (let ((bl-new (buffer-list)))
    (while bl-new
      (when (and (member (car bl-new) bl-old)
		 (not (member (buffer-name (car bl-new))
			      (list "*scratch*"
				    " *Minibuf-0*"
				    "*Messages*"))))
	(with-current-buffer (car bl-new)
	  (log-format "GC: \"%s\"" 
		      (buffer-name (car bl-new)))
	  (not-modified)
	  (kill-buffer (current-buffer))))
	(setq bl-new (cdr bl-new)))))

(defun flserver (action &rest args)
  (flserver-touch)
  (let ((bl-old (buffer-list)))
    (prog1 
	(unwind-protect
	    (cond 
	     ((eq action 'ping)
	      (apply #'flserver-ping (list)))
	     ((eq action 'xhtmlize)
	      (apply #'flserver-xhtmlize args))
	     ((eq action 'shtmlize)
	      (apply #'flserver-shtmlize args))
	     ((eq action 'cssize)
	      (apply #'flserver-cssize args))
	     ((eq action 'scssize)
	      (apply #'flserver-scssize args))
	     ((eq action 'shutdown)
	      (apply #'flserver-shutdown args))
	     )
	  (gc-buffers bl-old))
      (flserver-touch))))

(defun flserver-ping ()
  (with-log-string "ping" "" t))

(defun flserver-xhtmlize (src-file html-file css-dir)
  (with-log-string
   "xhtmlize" (format "src-file: %s, html-file: %s, css-dir: %s"
		      src-file html-file css-dir)
   (let ((xhtmlize-external-css-base-dir css-dir)
	 (xhtmlize-external-css-base-url (or flserver-xhtmlize-external-css-base-url
					     (concat "file://" css-dir))))
     (xhtmlize-file src-file html-file))))

(defun flserver-shtmlize (src-file shtml-file css-dir)
  (with-log-string
   "shtmlize" (format "src-file: %s, shtml-file: %s, css-dir: %s"
		      src-file shtml-file css-dir)
   (condition-case e
       (let ((xhtmlize-external-css-base-dir css-dir)
	     (xhtmlize-external-css-base-url (or flserver-xhtmlize-external-css-base-url
						 (concat "file://" css-dir))))
	 (shtmlize-file src-file shtml-file))
     (error 
      (log-string (error-message-string e))))))

(defun flserver-cssize (face css-dir requires)
  (with-log-string
   "cssize" (format "face: %s, css-dir: %s, requires %s"
		    face css-dir requires)
   (mapc #'require requires)
   (set-foreground-color "black")
   (set-background-color "white")
   (xhtmlize-cssize face css-dir "Default")
   (set-foreground-color "white")
   (set-background-color "black")
   (xhtmlize-cssize face css-dir "Invert")))

(defun flserver-scssize (face css-dir requires)
  (with-log-string
   "scssize" (format "face: %s, css-dir: %s, requires %s"
		     face css-dir requires)
   (mapc #'require requires)
   (set-foreground-color "black")
   (set-background-color "white")
   (xhtmlize-scssize face css-dir "Default")
   (set-foreground-color "white")
   (set-background-color "black")
   (xhtmlize-scssize face css-dir "Invert")))

(defun flserver-shutdown ()
  (log-string "lazy shutdown")
  (setq flserver-idle-timeout 0))



(defun flserver-server-start ()
  (cd "/")
  ;;
  (setq server-log t)
  (display-buffer (get-buffer-create server-buffer))
  ;;
  (condition-case e
      (with-log-string "server-start" ""
		       (server-start))
    (error 
     (log-string "Error in server-start")
     (flserver-kill-emacs 1)))
  (unless server-process
    (log-string "No server-process")
    (flserver-kill-emacs 1))
  )

(defun flserver-kill-emacs (n)
  (log-format "Kill emacs(%d)" n)
  (unless (and nil (eq n 0))
    (mapc
     (lambda (s) (log-format "<reason:Messages> %s" s) )
     (split-string
      (with-current-buffer "*Messages*"
	(buffer-string))
      "\n"))
    (mapc
     (lambda (s) (log-format "<reason:Server> %s" s) )
     (split-string
      (with-current-buffer server-buffer
	(buffer-string))
      "\n"))
    )
  (kill-emacs n))

;;
;; Main
;;
(defun flserver-main ()
  (flserver-server-start)
  (flserver-touch)
  (while t
    (when (flserver-timtout-p)
	(log-string "idle shutdown")
	(flserver-kill-emacs 0)
	)
    (sit-for flserver-period)))

(log-string "initializing...done")

;;
(run-with-idle-timer 1 nil 'flserver-main)

(provide 'flserver-main)
