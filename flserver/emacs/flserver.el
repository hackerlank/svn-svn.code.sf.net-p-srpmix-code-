;;
;; Configurations
;;
(defconst prefix "/home/masatake")
(defconst flserver-dir (concat "/home/masatake" "/" "var/flserver"))
(defconst flserver-emacs-dir (concat flserver-dir "/" "emacs"))
(setq load-path (cons flserver-emacs-dir load-path))


(setq server-socket-dir   "/home/masatake/tmp")
(setq server-name         ".flserver")


;;
;; Avoid interactive features
;;
;(setq enable-local-variables :safe)
(setq enable-local-variables nil)
(defun hack-local-variables (&optional mode-only)
  )


;;
;; Logging facilities
;;
(defvar flserver-log-buffer nil)
(defun flserver-log (str)
  (unless flserver-log-buffer
    (setq flserver-log-buffer 
	  (find-file-noselect (concat flserver-dir "/" "flserver-log.es"))))
  (with-current-buffer flserver-log-buffer
    (goto-char (point-max))
    (insert str)
    (save-buffer)))

;;
;; Server 
;;    
(setq server-raise-frame  nil)
(require 'server)
;;
;; **** DANGER ****, we should avoid this.
;;
(defun server-ensure-safe-dir (dir))


;;
;; Linum
;;
(require 'linum)

;;
;; Htmlize core
;;
(require 'htmlize)

;;
;; Font lockig
;;
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)
(progn 
  (set-background-color "black")
  (set-foreground-color "white")
  (set-face-foreground 'font-lock-comment-face "red1")
  (set-face-foreground 'linum "gray")
;  (set-face-background 'linum "white")
  (set-face-underline 'linum t)
  )


;;
;; Additional major modes
;;
;; javascript 
(add-to-list 'auto-mode-alist '("\\.js\\'" . espresso-mode))
(autoload 'espresso-mode "espresso" nil t)

;; lua
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(setq auto-mode-alist (cons '("\\.lua$" . lua-mode) auto-mode-alist))

;; php
(autoload 'php-mode "php-mode" "Php editing mode." t)
(setq auto-mode-alist (cons '("\\.php$" . php-mode) auto-mode-alist))

;; po
(autoload 'po-mode "po-mode" "Major mode for translators to edit PO files" t)
(setq auto-mode-alist (cons '("\\.po\\'\\|\\.po\\." . po-mode) auto-mode-alist))

;; rpm spec
(autoload 'rpm-spec-mode "rpm-spec-mode" "RPM spec mode." t)
(setq auto-mode-alist (cons '("\\.spec" . rpm-spec-mode) auto-mode-alist))

;; ruby
(autoload 'ruby-mode "ruby-mode" "Ruby mode." t)
(setq auto-mode-alist (cons '("\\.rb" . ruby-mode) auto-mode-alist))

;;
;; Main
;;
(defun flserver-htmlize (input output &optional range)
  (linum-mode)
  (let ((start (current-time)))
    (flserver-log (format "(start :time \"%s\" :input \"%s\" output: \"%s\" :range %s)\n" 
			  (current-time-string start) input output range))
    (if range
	(htmlize-file input output (car range) (cadr range)) 
      (htmlize-file input output))
    (flserver-log (format "(end :cost %s)\n" (- (float-time (current-time)) (float-time start) )))))

(server-start)
(while t
  (sit-for 3600))

(provide 'flserver)
