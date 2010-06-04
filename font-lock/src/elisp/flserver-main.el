(require 'flserver-decl)

;;
;; Extend load path
;;
(eval-when-compile
  (message "%s" process-environment))
(let* ((file (symbol-file 'flserver))
       (flserver-dir (concat 
		      (file-name-as-directory (file-name-directory file))
		      "flserver")))
  (setq load-path (cons flserver-dir load-path)))


;;
;; Enable logging
;;
(require 'log)
(log-set-identity "flserver")
(when flserver-log-file
  (log-set-file flserver-log-file))
(log-string "initializing...")


;;
;; Disable interactive features
;;
(setq enable-local-variables nil)


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
(flserver-touch)


;;
;; Load libraries
;;
(require 'xhtmlize)
(require 'cssize)

;;
;; Entry point for client
;;
(defun flserver-entry (action &rest args)
  (flserver-touch)
  (cond 
   ((eq action 'xhtmlize)
    (apply #'flserver-xhtmlize args))
   ((eq action 'cssize)
    (apply #'flserver-cssize args))
   ))

(defun flserver-xhtmlize (src-file html-file css-dir)
  (with-log-string
   "xhtmlize" (format "src-file: %s, html-file: %s, css-dir: %s"
		      src-file html-file css-dir)
   (let ((xhtmlize-external-css-base-dir css-dir)
	 (xhtmlize-external-css-base-url (or flserver-xhtmlize-external-css-base-url
					     (concat "file://" css-dir))))
     (xhtmlize-file src-file html-file))))

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

;;
;; Main
;;
(defun flserver-main ()
  (message "Hello world")
  (server-start)
  (while t
    (when (flserver-timtout-p)
	(log-string "idle shutdown")
	(kill-emacs 0)
	)
    (sit-for flserver-period)
    ))

(log-string "initializing...done")
(flserver-main)

(provide 'flserver-main)
