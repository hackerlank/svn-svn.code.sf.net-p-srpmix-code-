(require 'dired)

(defmacro define-dired-face (name)
  `(defface ,name '((t :inherit default))
     "Dummy face for yogomacs.dired"))
(defmacro define-dired-faces (&rest list)
  `(progn
     ,@(mapcar
	(lambda (name)
	  `(define-dired-face ,name))
	`(,@list))))

(define-dired-faces 
  dired-regular
  dired-unknown
  dired-symlink-arrow
  dired-symlink-to
  dired-executable
  dired-entry-type
  dired-size
  dired-date)

(provide 'xhtmlize+dired-main)
