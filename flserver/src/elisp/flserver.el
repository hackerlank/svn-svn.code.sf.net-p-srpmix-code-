(defconst config-file "/home/masatake/var/flserver/config.es")

(defvar flserver-dir nil)
(defvar flserver-emacs-dir nil)
(defvar flserver-socket-file nil)
(defvar flserver-cache-log nil)

;; THIS SHOULD BE ON COMMAND LINE.
(require 'es)
(require 'cl)
(let* ((b (find-file-noselect config-file))
       (s (es-make-input-stream b))
       (r t))
  (setq r (es-read s))
  (while r
    (when (and 
	   (listp r)
	   (eq (car r) (intern "conf")))
      (let ((key (nth 1 r))
	    (value (nth 2 r)))
	(case key
	  ('flserver-prog-dir
	   (setq flserver-dir value))
	  ('emacs-prog-dir
	   (setq flserver-emacs-dir value))
	  ('socket-file
	   (setq flserver-socket-file value))
	  ('cache-log
	   (setq flserver-cache-log value))
	  ('css-dir
	   (setq xhtmlize-external-css-base-dir value))
	  ('web-dir
	   (setq xhtmlize-linum-web-dir value))
	  ('api-url
	   (setq xhtmlize-linum-api-url value))
	  ('web-url
	   (setq xhtmlize-linum-web-url value))
	  )))
    (setq r (es-read s)))
  (kill-buffer b))

    
;;
;; Configurations
;;
(setq load-path (cons flserver-emacs-dir load-path))

(setq server-socket-dir (directory-file-name 
			 (file-name-directory 
			  flserver-socket-file)))
(setq server-name       (file-name-nondirectory flserver-socket-file))

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
(setq make-backup-files nil)
(defvar flserver-log-buffer nil)
(defun flserver-log (str)
  (unless flserver-log-buffer
    (setq flserver-log-buffer 
	  (find-file-noselect flserver-cache-log)))
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
;; Cssize
;;
(require 'dired)
(require 'cssize)

;;
;; xHtmlize core
;;
(require 'xhtmlize)
(setq xhtmlize-body-pre-tags 
      (concat xhtmlize-body-pre-tags
;	      "<script type=\"text/javascript\" src=\"http://srpmix.org/api/js/biwascheme.js\">\n"
;	      "(load \"http://srpmix.org/api/scm/yogomacs.scm\")\n"
;	      "</script>\n"
	      ""
	      ))
(setq xhtmlize-body-post-tags
      (concat xhtmlize-body-post-tags
	      "<div class=\"default\" id=\"bs-console\"></div>\n"
	      "<script type=\"text/javascript\" src=\"http://srpmix.org/api/js/biwascheme.js\">\n"
	      "(load \"http://srpmix.org/api/scm/yogomacs.scm\")\n"
	      "</script>\n"
	      ))

;; plugins
(require 'xhtmlize+linum)


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
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(autoload 'js2-mode "js2" nil t)

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
(defvar flserver-timestamp (current-time))

(defun flserver-xhtmlize (input output)
  (setq flserver-timestamp (current-time))
  (linum-mode 1)
  (let ((start (current-time)))
    (flserver-log 
     (format "(xhtml-start :time \"%s\" :input \"%s\" output: \"%s\")\n" 
	     (current-time-string start) input output))
    (xhtmlize-file input output)
    (flserver-log 
     (format "(xhtml-end :cost %s)\n" 
	     (- (float-time (current-time)) 
		(float-time start) )))
    (setq flserver-timestamp (current-time))))

(defun flserver-cssize (face output)
  (setq flserver-timestamp (current-time))
  (let ((start (current-time)))
    (flserver-log 
     (format "(css-start :time \"%s\" :face %s output: \"%s\")\n" 
	     (current-time-string start) face output))
    (cssize-file face output)
    (flserver-log 
     (format "(css-end :cost %s)\n" 
	     (- (float-time (current-time)) 
		(float-time start) ))))
  (setq flserver-timestamp (current-time)))


(server-start)
(let ((flag t))
  (while flag
    (when (> (nth 1 (time-subtract (current-time) old)) 90)
      (flserver-log 
     (format "(flserver-idle-shutdown :time \"%s\")\n" 
	     (current-time-string)))
      (kill-emacs 0))
    (sit-for 60)))

(provide 'flserver)
