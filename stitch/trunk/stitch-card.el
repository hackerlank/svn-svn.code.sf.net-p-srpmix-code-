(require 'electric)
(require 'stitch)

(defvar stitch-card-current nil)
(defvar stitch-card-forward-list nil)
(defvar stitch-card-backward-list nil)
(defun stitch-card-next ()
  (interactive)
  (if stitch-card-current
      (setq stitch-card-current (cadr (member stitch-card-current stitch-card-forward-list)))
    (setq stitch-card-current (car stitch-card-forward-list)))
  (if stitch-card-current
      (let ((file (stitch-klist-value stitch-card-current :file)))
	(stitch-target-jump stitch-card-current file)
	(recenter)
	(message "%s" file))
    (setq stitch-card-current (car stitch-card-backward-list))
    (message "%s" "<end>")))

(defun stitch-card-prev ()
  (interactive)
  (when stitch-card-current
    (setq stitch-card-current (cadr (member stitch-card-current stitch-card-backward-list)))
    (if stitch-card-current
	(let ((file (stitch-klist-value stitch-card-current :file)))
	  (stitch-target-jump stitch-card-current file)
	  (recenter)
	  (message "%s" file))
      (setq stitch-card-current (car stitch-card-forward-list))
      (message "%s" "<end>"))))

(defvar stitch-card-mode-map 
  (let ((map (make-sparse-keymap)))
    (define-key map " " 'stitch-card-next)
    (define-key map [backspace] 'stitch-card-prev)
    (define-key map "q" 'stitch-card-mode)
    map))
    
(define-minor-mode stitch-card-mode
  ""
  nil " StitchCard" stitch-card-mode-map :global t)

(defun stitch-card-compile (list)
  (let ((l (with-temp-buffer
	     (let ((l (delete nil (mapcar
				   (lambda (elt)
				     (if (and (listp elt)
					      (eq (car elt) 'stitch-annotation))
					 elt
				       nil))
				   list))))
	       (princ l)
	       (goto-char (point-min))
	       (stitch-load-annotation (current-buffer) "/tmp")
	       
	       l))))
    (let ((L (list)))
      (mapc (lambda (r)
	      (setq L (append (stitch-klist-value r :target-list) L)))
	  l)
      L
      (setq stitch-card-current nil
	    stitch-card-forward-list (reverse L)
	    stitch-card-backward-list L))))

(stitch-card-compile 
'(stitch-card example
	     (stitch-annotation :version 0 :target-list ((target :type file :file "/usr/share/emacs/23.1/lisp/electric.el.gz" :point 981 :coding-system undecided-unix :line 31)) :annotation-list ((annotation :type text :data "ここで説明がある。")) :date "Tue Oct 27 04:13:06 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))
	     (stitch-annotation :version 0 :target-list ((target :type file :file "/usr/share/emacs/23.1/lisp/electric.el.gz" :point 2414 :coding-system undecided-unix :line 53 :which-func ("Electric-command-loop"))) :annotation-list ((annotation :type text :data "ここがメイン関数")) :date "Tue Oct 27 04:13:18 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))
	     (stitch-annotation :version 0 :target-list ((target :type file :file "/usr/share/emacs/23.1/lisp/electric.el.gz" :point 5345 :coding-system undecided-unix :line 141 :which-func ("Electric-pop-up-window"))) :annotation-list ((annotation :type text :data "おまけ")) :date "Tue Oct 27 04:13:29 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))))