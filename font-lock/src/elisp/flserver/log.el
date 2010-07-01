(defvar log-ident "emacs")
(defun log-set-identity (ident)
  (setq log-ident ident))

(defun log-string (str)
  (let ((str (format "%s [%d]" str (emacs-pid))))
    (message "%s %s %s: %s" 
	     (current-time-string) mail-host-address log-ident str)
    (call-process "logger"
		  nil
		  nil
		  nil
		  "-i"
		  "-t"
		  log-ident
		  "--"
		  str)))

(defun log-format (fmt &rest args)
  (let ((str (apply #'format fmt args)))
    (log-string str)))

(defun log+error (fmt &rest args)
  (let ((str (apply #'format fmt args)))
    (log-string str)
    (error "%s" str)))

(defmacro with-log-string (key str &rest body)
  
  `(progn
     (log-format "%s-start %s" ,key ,str)
     ,@body
     (log-format "%s-end %s" ,key ,str)))

(provide 'log)
