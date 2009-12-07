(defun dive-idle-do ()
  (when (and (boundp 'dive-sources-buffer)
	     dive-sources-buffer)
    ;;
    (message "->%s" (current-time-string))
    (redisplay)))

(defvar dive-idle-id nil)
(defun dive-idle-start ()
  (if dive-idle-id
      (message "Dive idle already started: %s" dive-idle-id)
    (setq dive-idle-id (run-with-idle-timer 1 t 'dive-idle-do))
    (message "Dive idle starts: %s" dive-idle-id)))

(defun dive-idle-stop ()
  (if dive-idle-id
      (progn (cancel-timer dive-idle-id)
	     (message "Dive idle stops: %s" dive-idle-id)
	     (setq dive-idle-id nil))
    (message "Dive idle already stopped")))

(provide 'dive-idle-action)
