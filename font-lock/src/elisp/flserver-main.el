;;
;; Extend load path
;;
(defconst flserver t)
(let* ((file (symbol-file 'flserver))
       (flserver-dir (concat 
		      (file-name-as-directory (file-name-directory file))
		      "flserver")))
  (setq load-path (cons flserver-dir load-path)))

;;
;; Enable logging
;;
(require 'logging)
(flserver-start-lagging)

;;
;; Disable unnecessary interactive features
;;

;;
;; xhtmlize and cssize setup
;;

;;
;; Server  setup
;;    
(setq server-raise-frame  nil)
(require 'server)

;;
;; Load plugins
;;

;;
;; Load extra modes
;;

;;
;; **** DANGER ****, we should avoid this.
;;
(defun server-ensure-safe-dir (dir))

;;
;; main
;;

(provide 'flserver-main)
