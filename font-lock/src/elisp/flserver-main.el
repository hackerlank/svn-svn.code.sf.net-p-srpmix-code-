(require 'flserver-decl)

;;
;; Extend load path
;;
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
;; Entry point for client
;;
(defun flserver-entry (str)
  (flserver-touch)
  (log-string "accept request")
  (message "%s" str)
  )


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
