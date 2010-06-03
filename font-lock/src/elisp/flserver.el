(defconst flserver t)
(let* ((file (symbol-file 'flserver))
       (flserver-dir (concat 
		      (file-name-as-directory (file-name-directory file))
		      "flserver")))
  (setq load-path (cons flserver-dir load-path)))

;;
;; Server 
;;    
(setq server-raise-frame  nil)
(require 'server)
;;
;; **** DANGER ****, we should avoid this.
;;
(defun server-ensure-safe-dir (dir))

(provide 'flserver)
