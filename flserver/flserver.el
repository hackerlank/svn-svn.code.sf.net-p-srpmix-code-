(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

(require 'htmlize)
;; http://www.emacswiki.org/emacs/download/htmlize.el

(require 'server)
(setq server-raise-frame  nil)
(setq server-socket-dir   "/home/masatake/tmp")
(setq server-name         ".flserver")

(defun flserver-htmlize (input output-dir)
  (htmlize-file input output-dir)
  )

;; DANGER, we should avoid this.
(defun server-ensure-safe-dir (dir))
(server-start)

(while t
  (sit-for 3600))
(provide 'flserver)
