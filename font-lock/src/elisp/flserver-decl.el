(defvar flserver-server-name "flserver")
(defvar flserver-idle-timeout 180)
(defvar flserver-period 5)
(defvar flserver-log-max 1024)



(defvar flserver-xhtmlize-external-css-base-url nil)

(provide 'flserver-decl)

(require 'flserver-boot)
(flserver-extend-load-path)
(flserver-load-plugin-decls)
;; TODO load decls of each plugins 
