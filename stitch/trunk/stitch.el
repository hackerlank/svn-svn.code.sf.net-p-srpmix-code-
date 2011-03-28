;;; stitch.el --- your source, my annotation

;; Copyright (C) 2007, 2008, 2009 Red Hat, Inc.
;; Copyright (C) 2007, 2008, 2009, 2010 Masatake YAMATO

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; With this program you can insert your own annotations to source code
;; file(the source file) without changing the source code file itself;
;; your annotations datum are written to a file separated from the source
;; file. Emacs stitchs your annotations and the source file into a buffer
;; when you do C-x C-f the source file on the fly. The annotations are
;; represented as overlays on emacs buffer. So datum on the bufffer coming
;; from the source file is NOT changed.

;; I wrote this program for my son.

;; Advantages
;; ----------

;; Annotations can take del.icio.us like keywords. You can list
;; annotations by the keywords.

;; Multiple annotations can be merged easily. The annotations are
;; recorded as S expressions. For merging multiple annotation files
;; what you need is just `cat' command. Further more you can hack
;; annotation files with a scheme/lisp interpreter.

;; Multiple annotation formatter are supported. Text is the simplest 
;; for matter. However, graphviz and mscgen drawing are also supported. 
;; If you wrote your annotation in dot format, emacs runs dot(, circo, 
;; twopi or mscgen) and astitch the result png image into the buffer.

;; Not only file but also dired buffers are supported. You can make
;; annotations even on files and sub-directories in a directory opened
;; by dired. This is helpful if you want to explain a directory
;; structure in a package.

;; You can put single annotation to multiple place with emacs register
;; facility. If you modify the original annotation, the all stitchd
;; annotations are updated.

;; Restriction
;; -----------
;; The source file should be not be changed; the places where
;; annotations are stitchd are represented in the (point) of buffer. 
;; So if the source code is changed, the annotations are not stitchd
;; properly. 

;; The annotation once recorded cannot be edited easily.
;; The knowledges about S expression are needed to edit them.

;; The large annotation cannot be displayed well because
;; overlay is used to show an annotation.

;; Many temporary files are created during weaving. They are
;; not delete automatically.

;; Background
;; ----------
;; For GNU generation, reading the source code written by another people
;; is key primary skill even comparing with writing. However, generally
;; the process of source code reading is secret to private; people talks
;; only about knowledges, the result of reading, not reading itself. I 
;; wonder how the greate hackers read source code; how they think during 
;; reading. Before asking such questions to them, I think I should show
;; how I do it. I wrote this tool for recording what and how I think during 
;; code reading.

;; stitch annotation format
;; -------------------------

;; ANNOTATION
;; ==========
;; (stitch-annotation  :version 0
;;                     :target-list (TARGET ...)
;;                     :annotation-list (ANNOTATION...)
;; 		       :date DATE
;; 		       :full-name STRING
;; 		       :mailing-address STRING
;; 		       :keywords (KEYWORD...))
;;
;; TARGET
;; ^^^^^^
;; General format: (target :type TYPE &rest args)
;; ARGS depends on TYPE.
;;
;; (target :type file :file PATH :point P [:which-func FUNCTION] [:line LINE] [:surround SURROUND])
;; (target :type directory :directory PATH :item FILE-or-SUBDIR)
;;
;; SURROUND
;; ^^^^^^^^
;; General format: (front-text this-text rear-text)
;; 
;;
;; ANNOTATION
;; ^^^^^^^^^^
;; General format: (annotation :type TYPE :data DATA)
;; DATA depends on TYPE.
;;
;; TYPE: test, dot...
;;
;; KEYWORD
;; =======
;; (define-keyword SYMBOL
;;                 :version 0
;;                 :subject STRING
;;                 [:parent KEYWORD]
;;                 :date DATE
;;                 :full-name STRING
;;                 :mailing-address STRING)
;;
;; (define-keyword SYMBOL
;;                 :version 0
;;                 :subject STRING
;;                 [:parent KEYWORD]
;;                 :date DATE
;;                 :full-name STRING
;;                 :mailing-address STRING)
;;
;;
;; TODO
;;
;; - Tooltips
;; - Lazy rendering
;; - Edit annotatoins.
;; - Delete tmp files.
;; - Hub annotation by register
;;

;;; Codes:
(require 'add-log)
(require 'which-func)
(require 'cl)				; for mapcar*

(defgroup stitch nil
  "Tool to stitch your annotation into source code"
  :group 'tools
  :prefix "stitch-")

(defface stitch-annotation-base
  '((((background light)) 
     (:background "gray80"))
    (((background dark)) 
     (:background "gray20")))
  "Base face used to highlight anntations in source code."
  :group 'stitch)

(defface stitch-annotation-fuzzy
  '((((background light)) 
     (:background "gray70" :italic t))
    (((background dark)) 
     (:background "gray30" :italic t)))
  "Similar to stitch-annotation-base but used in fuzzy matched anntations."
  :group 'stitch)

(defface stitch-annotation-date
  '((t (:inherit (change-log-date stitch-annotation-base))))
  "Face used to highlight date in anntations."
  :group 'stitch)

(defface stitch-annotation-body
  '((t (:inherit (font-lock-comment-face stitch-annotation-base))))
  "Face used to highlight anntation body."
  :group 'stitch)

(defface stitch-annotation-registered-as-line
  '((t (:inherit (stitch-annotation-body))))
  "Face used to highlight registered-as line."
  :group 'stitch)

(defface stitch-annotation-email
  '((t (:inherit (change-log-email stitch-annotation-base))))
  "Face used to highlight email addresses in anntations."
  :group 'stitch)

(defface stitch-annotation-name
  '((t (:inherit (change-log-name stitch-annotation-base))))
  "Face used to highlight full names in anntations."
  :group 'stitch)

(defface stitch-annotation-edit-header
  '((t (:inherit (font-lock-comment-face stitch-annotation-base))))
  "Face used to highlight the header of annotation editing buffer."
  :group 'stitch)

(defface stitch-annotation-summary-title
  '((t (:background "gray20")))
  "Face used to highlight the header of annotation editing buffer."
  :group 'stitch)

(defface stitch-marker
  '((t (:background "yellow")))
  "Face used to highlight the annotated region."
  :group 'stitch)

(defface stitch-strike-through-marker
  '((t (:strike-through "red")))
  "Face used to highlight the annotated region."
  :group 'stitch)

(defcustom stitch-annotation-file (format "~/.stitch.es" (user-login-name))
  "file where your annotations are stored to"
  :type 'file
  :group 'stitch)

(defcustom stitch-annotation-external-files ()
  "files and directories where your readonly annotations are stored to"
  :type '(repeat (choice file directory))
  :group 'stitch)

(defcustom stitch-annotation-inline-show-header nil
  "Show date, name and mail-address in inline annotation"
  :set (lambda (symbol value)
	 (set-default symbol value)
	 (when (fboundp 'stitch-reload-annotations)
	   (stitch-reload-annotations t t)))
  :type  'boolean
  :group 'stitch)

;;
;; Utils
;;
(defun stitch-annotation-toggle-show-header ()
  (interactive)
  (setq stitch-annotation-inline-show-header
	(not stitch-annotation-inline-show-header))
  (stitch-reload-annotations t t))

(defun stitch-read-safely (stream)
  (condition-case nil
      (read stream)
    (error nil)))

;(stitch-klist-value '(x 1 2 :a "a" :b "b") :b) => "b"
(defun stitch-klist-value (klist keyword)
  (if klist
      (if (keywordp (car klist))
	  (if (eq keyword (car klist))
	      (cadr klist)
	    (stitch-klist-value (cddr klist) keyword))
	(stitch-klist-value (cdr klist) keyword))
	nil))

(defun stitch-klist-append (klist keyword value)
  (reverse (cons value (cons keyword (reverse klist)))))

(defun stitch-buffer-file-name (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (or (buffer-file-name)
	(and (eq major-mode 'dired-mode) (expand-file-name dired-directory))
	(when (eq major-mode 'rfc-index-mode) (buffer-name)))))

(defun stitch-make-completion-string-list (hash)
  (let ((table ()))
    (maphash
     (lambda (k v)
       (setq table (cons (symbol-name k) table)))
     hash)
    table))

(defun stitch-gather-undefined-keywords ()
  (let ((gathered ()))
    (maphash (lambda (k v)
	       (mapc
		(lambda (e)
		  (mapc
		   (lambda (s)
		     (when (and (symbolp s)
				(not (member s gathered)))
		       (setq gathered (cons s gathered))))
		   (stitch-klist-value e :keywords))
		  )
		v))
	     stitch-annotations)
    gathered))

(defvar stitch-read-keywords-history ())
(defun stitch-read-keywords (prefix multi &optional recursion)
  (let ((s (completing-read (format "%sKeyword%s<%s>: "
				    (if prefix (concat prefix " ") "")
				    (if multi "s" "")
				    (if multi "multi" "single"))
			    (append
			     (stitch-make-completion-string-list stitch-keywords)
			     (mapcar 'symbol-name (stitch-gather-undefined-keywords)))
			    nil nil
			    (unless recursion (car stitch-read-keywords-history))
			    'stitch-read-keywords-history)))
    (if (string= s "")
	nil
      (cons (intern s)
	    (if multi
		(stitch-read-keywords prefix multi t)
	      ())))))

(defun stitch-make-annotation-header (date full-name mailing-address fuzzy?)
  (let ((base-face (if fuzzy? 'stitch-annotation-fuzzy 'stitch-annotation-base)))
    (if stitch-annotation-inline-show-header
	(concat
	 (propertize date 'face 'stitch-annotation-date)
	 (propertize "  " 'face base-face)
	 (propertize full-name 'face 'stitch-annotation-name)
	 (propertize "  <" 'face base-face)
	 (propertize mailing-address 'face 'stitch-annotation-email)
	 (propertize ">" 'face base-face)
	 (propertize "\n\n" 'face base-face))
      "")))

(defmacro stitch-with-current-file (f &rest body)
  `(let* ((loaded (get-file-buffer ,f))
	  (result (with-current-buffer (find-file-noselect ,f)
		    (prog1 (progn ,@body)
		      (unless loaded
			(kill-buffer (current-buffer)))))))
     result))
(put 'stitch-with-current-file 'lisp-indent-function 1)

(defun stitch-get-user-full-name ()
  (or add-log-full-name (user-full-name)))

(defun stitch-get-user-mailing-address ()
  (or add-log-mailing-address user-mail-address))

(defun stitch-annotation-compare (e1 e2)
  (let ((et1 (date-to-time (stitch-klist-value e1 :date)))
	(et2 (date-to-time (stitch-klist-value e2 :date))))
    (cond
     ((> (car et1) (car et2)) nil)
     ((< (car et1) (car et2)) t)
     (t
      (cond
       ((> (cadr et1) (cadr et2)) nil)
       ((< (cadr et1) (cadr et2)) t)
       (t
	(equal (stitch-klist-value e1 :full-name)
	       (stitch-get-user-full-name))))))))

(defvar stitch-annotations (make-hash-table :test 'equal))
(defvar stitch-annotations-fuzzy (make-hash-table :test 'equal))
(defvar stitch-keywords    (make-hash-table :test 'eq))

;;
;; Target handler table
;;
(defvar stitch-target-handlers (make-hash-table :test 'eq))
(defun stitch-get-target-handler (type-or-target)
  (cond
   ((symbolp type-or-target)
    (let ((handler (gethash type-or-target
			    stitch-target-handlers
			    ())))
      (or handler
	  (error (format "No such target type: %S" type-or-target)))))
   ((listp type-or-target)
    (stitch-get-target-handler
     (stitch-klist-value type-or-target :type)))
   (t
    (error (format "No way to get target type from: %S" type-or-target)))))
(defun stitch-register-taregt-handlers (type klist)
  (puthash type klist stitch-target-handlers))

(defun stitch-target-new (type)
  (let ((handler (stitch-get-target-handler type)))
    (funcall (stitch-klist-value handler :make))))
(defun stitch-target-load (es)
  (let ((handler (stitch-get-target-handler
		  (stitch-klist-value es :type))))
    (funcall (stitch-klist-value handler :load)
	     es)))
(defun stitch-target-type (target)
  (stitch-klist-value target :type))
(defun stitch-target-invoke-method (target k-method &rest args)
  (let ((handler (stitch-get-target-handler target)))
    (let ((func (stitch-klist-value handler k-method)))
      (if func
	  (apply func
		 target
		 args)
	(error (format "No such method: %S for target: %S" k-method target))))))
(defun stitch-target-get-files (target)
  (stitch-target-invoke-method target :get-files))
(defun stitch-target-get-point (target file)
  (stitch-target-invoke-method target :get-point file))
(defun stitch-target-get-region (target file)
  (stitch-target-invoke-method target :get-region file))
(defun stitch-target-get-label (target file)
  (stitch-target-invoke-method target :get-label file))
(defun stitch-target-save-form (target)
  (stitch-target-invoke-method target :save-form))
(defun stitch-target-jump (target file)
  (stitch-target-invoke-method target :jump file))

;;
;; Annotation handler table
;;

(defvar stitch-annotation-handlers (make-hash-table :test 'eq))
(defun stitch-get-annotation-handler (type-or-annotation)
  (cond
   ((symbolp type-or-annotation)
    (let ((handler (gethash type-or-annotation
			    stitch-annotation-handlers
			    ())))
      (or handler
	  (error (format "No such annotation type: %S"
			 type-or-annotation)))))
   ((listp type-or-annotation)
    (stitch-get-annotation-handler
     (stitch-klist-value type-or-annotation :type)))
   (t
    (error (format "No way to get annotation type from: %S"
		   type-or-annotation)))))
(defun stitch-register-annotation-handler (type klist)
  (puthash type klist stitch-annotation-handlers))

(defun stitch-annotation-new (type commit-func commit-args)
  (let ((handler (stitch-get-annotation-handler type)))
    (funcall (stitch-klist-value handler :make) commit-func commit-args)))
(defun stitch-annotation-load (es)
  (let ((handler (stitch-get-annotation-handler
		  (stitch-klist-value es :type))))
    (funcall (stitch-klist-value handler :load)
	     es)))
(defun stitch-annotation-invoke-method (annotation k-method &rest args)
  (let ((handler (stitch-get-annotation-handler annotation)))
    (let ((func (stitch-klist-value handler k-method)))
      (if func
	  (apply func
		 annotation
		 args)
	(error
	 (format "No such method: %S for annotation: %S"
		 k-method annotation))))))

(defun stitch-annotation-save-form (annotation)
  (stitch-annotation-invoke-method annotation :save-form))

(defun stitch-annotation-inline-format (annotation 
					overlay
					date 
					full-name
					mailing-address
					fuzzy?)
  (stitch-annotation-invoke-method annotation :inline-format
				   overlay
				   date full-name mailing-address
				   fuzzy?))

(defun stitch-annotation-list-format (annotation)
  (stitch-annotation-invoke-method annotation :list-format))

;;
;; Frontend
;;
;; (defun stitch-make-annotation-hash (annotation)
;;   (let ((h (make-hash-table :test 'eq))
;; 	(f (lambda (h a)
;; 	     (if (null a)
;; 		 h
;; 	       (puthash (car a) (cadr a) h)
;; 	       (funcall 'f (cddr a) h)))))
;;     (funcall 'f annotation h)))

(defun stitch-draw-marker ()
  (interactive)
  (stitch-annotate 'oneline t))

(defun stitch-annotate-text ()
  (interactive)
  (stitch-annotate 'text nil))

(defun stitch-target-from-register (reg)
  (interactive "cRegister: ")
  (let ((target (let ((m (get-register reg)))
		  (when (markerp m)
		    (with-current-buffer (marker-buffer m)
		      (save-excursion
			(goto-char m)
			(stitch-target-new
			 (if (eq major-mode 'dired-mode) 'directory 'file))))))))
    (when (interactive-p)
      (insert (format "%S" target)))
    target))

(defun stitch-read-target-registers (seed regs)
  (let ((r (read-char (format "[%s] Target Register(return for end): "
			       (mapconcat
				(lambda (c) (char-to-string c))
				(reverse regs)
				" ")
			      ))))
    (cond
     ((or (eq r ?\r) (eq r ?\n)) seed)
     ((member r regs)
      (message "`%c' are already added as a target" r)
      (sit-for 1)
      (stitch-read-target-registers seed regs))
     (t
      (let ((target (stitch-target-from-register r)))
	(if target
	    (stitch-read-target-registers (cons target seed)
					   (cons r regs))
	  (message "`%c' doesn't contain a marker" r)
	  (sit-for 1)
	  (stitch-read-target-registers seed regs)))))))

(defun stitch-buffers-from-target-list (target-list seed)
  (if target-list
      (let ((target (car target-list)))
	;; TODO: use all files in the returned list.
	(stitch-buffers-from-target-list (cdr target-list)
					  (cons
					   (find-file-noselect
					    (car (stitch-target-get-files
						  target)))
					  seed)))
    seed))

(defun stitch-points-from-target-list (target-list seed)
  (if target-list
      (let ((target (car target-list)))
	;; TODO: use all files in the returned list.
	(stitch-points-from-target-list (cdr target-list)
					 (cons
					  (stitch-target-get-point
					   target
					   (car (stitch-target-get-files
						 target)))
					  seed)))
    seed))

(defun stitch-regions-from-target-list (target-list seed)
  (if target-list
      (let ((target (car target-list)))
	;; TODO: use all files in the returned list.
	(stitch-regions-from-target-list (cdr target-list)
					 (let ((new (stitch-target-get-region
						     target
						     (car (stitch-target-get-files
							   target)))))
					   (if new
					       (cons
						new
						seed)
					     seed
					     ))))
    seed))



(defun stitch-annotate (type use-region)
  (interactive (list (intern (completing-read "Type: "
					      (stitch-make-completion-string-list
					       stitch-annotation-handlers)
					      nil
					      t))
		     current-prefix-arg))
  (let ((target-type (if (eq major-mode 'dired-mode) 
			 'directory
		       (if use-region 
			   'region
			   'file)))
	(annotation-type type)
	(date (current-time-string))
	(full-name (stitch-get-user-full-name))
	(mailing-address (stitch-get-user-mailing-address)))
    (let ((target (stitch-target-new target-type)))
      (let* ((point (stitch-target-get-point target
					      (stitch-buffer-file-name)))
	     (label (stitch-target-get-label target
					      (stitch-buffer-file-name)))
	     (commit-func (lambda (data args post-data commit-prefix)
			    (let ((target (stitch-klist-value args :target))
				  (date   (stitch-klist-value args :date))
				  (full-name (stitch-klist-value args :full-name))
				  (mailing-address (stitch-klist-value args :mailing-address))
				  (buffer (stitch-klist-value args :buffer))
				  (point (stitch-klist-value args :point)))
			      (let* ((target-list (cons target
							(if (not commit-prefix)
							    (list)
							  (stitch-read-target-registers (list)
											 (list)))))
				     (buffers (stitch-buffers-from-target-list target-list
										(list)))
				     (regions (stitch-regions-from-target-list
					       target-list
					       (list))))
				(stitch-commit-annotation data
							  target-list
							  date
							  full-name
							  mailing-address
							  buffers
							  regions
							  post-data)))))
	     (commit-args `(:target ,target
			    :date   ,date
			    :full-name ,full-name
			    :mailing-address ,mailing-address
			    :buffer ,(current-buffer)
			    :point ,point
			    :label ,label)))
	(stitch-annotation-new annotation-type
				commit-func
				commit-args)))))

(defun stitch-commit-annotation (annotation
				 target-list
				 date full-name mailing-address
				 buffers regions
				 keywords)
  (let ((home-r (stitch-save-annotation
		 (mapcar 'stitch-target-save-form target-list)
		 annotation date full-name mailing-address keywords)))
    (mapcar*
     (lambda (target b r)
       ;; TODO
       (stitch-register-annotation target annotation
				   date full-name mailing-address keywords
				   home-r)
       ;;
       (stitch-insert-annotation0   b r
				    annotation date full-name mailing-address keywords nil))
     target-list buffers regions)))


(defun stitch-register-annotation (target annotation date full-name mailing-address keywords
					  annotation-home)
  (mapcar
   (lambda (file)
     (let ((entry (list :registered-as file
			:target target
			:annotation annotation
			:date date
			:full-name full-name
			:mailing-address mailing-address
			:keywords keywords
			:annotation-home annotation-home)))
       (puthash file 
		(cons entry (gethash file stitch-annotations ()))
		stitch-annotations)
       (cond
	;; TODO: This should be method invocation: fuzzy-insertable-p
	((stitch-klist-value target :surround)
	 (let ((base-name (file-name-nondirectory file)))
	   (puthash base-name
		    (cons entry (gethash base-name stitch-annotations-fuzzy ()))
		    stitch-annotations-fuzzy)))
	((eq (stitch-klist-value target :type) 'directory)
	 (let ((base-name (file-name-nondirectory (directory-file-name file))))
	   (puthash base-name
		    (cons entry (gethash base-name stitch-annotations-fuzzy ()))
		    stitch-annotations-fuzzy)
	 )))
       entry))
   (stitch-target-get-files target)))

(defun stitch-count-record ()
  (let ((i 0))
    (save-excursion
      (while (not (bobp))
	(backward-sexp)
	(setq i (+ i 1))
	))
    i))
  
(defun stitch-save-annotation (target-list annotation date full-name mailing-address keywords)
  (stitch-with-current-file stitch-annotation-file
    (goto-char (point-max))
    (let ((start (point))
	  (index (progn
		   ;; TODO: print
		   (insert (format "%S\n" (list 'stitch-annotation
						:version 0
						:target-list target-list
						:annotation-list (list (stitch-annotation-save-form annotation))
						:date date
						:full-name full-name
						:mailing-address mailing-address
						:keywords keywords)))
		   (save-buffer)
		   (stitch-count-record))))
    (list stitch-annotation-file
	  start
	  (point)
	  index))))

(defface stitch-auto-annotation
  '((((background light)) 
     (:foreground "gray45" :background "gray96"
		  :italic t :underline nil))
    (((background dark)) 
     (:foreground "gray30" 
		  :italic t :underline nil)))
  ""
  :group 'stitch)



(defun stitch-stitch-by-line-and-col (buffer line col si-proc keywords)
  (stitch-stitch buffer (with-current-buffer buffer 
			   (goto-line line)
			   ;;(line-move-to-column col)
			   (forward-char col)
			   (point))
		  si-proc keywords))

(defun stitch-stitch (buffer pos si-proc keywords)
  (with-current-buffer buffer
    (when (<= pos (point-max))
      (let* ((o (make-overlay pos pos buffer))
	     (si (funcall si-proc o)))
	(overlay-put o 'after-string si)
	;;      (overlay-put o 'display `((margin left-margin) "XXX"))
	(overlay-put o 'stitch-annotation t)
	(overlay-put o 'stitch-master-string si)
	(overlay-put o 'stitch-keywords keywords)
	o))))

(defun stitch-insert-point-annotation (buffer pos annotation date full-name mailing-address keywords fuzzy?)
  (with-current-buffer buffer
    (when (<= pos (point-max))
      (let* ((o (make-overlay pos pos buffer))
	     (si (stitch-annotation-inline-format annotation
						   o
						   date
						   full-name
						   mailing-address
						   fuzzy?)))
	;; FILTER the SI length here.
	(overlay-put o 'after-string si)
	;;      (overlay-put o 'display `((margin left-margin) "XXX"))
	(overlay-put o 'stitch-annotation t)
	(overlay-put o 'stitch-master-string si)
	(overlay-put o 'stitch-keywords keywords)
	o))))

;;
;;(require 'skk)
(require 'avoid)
(defun stitch-tooltip-show-at-point (text)
  (let* ((P (mouse-avoidance-point-position))
	 (frame (car P))
	 (x (cadr P))
	 (y (cddr P))
	 (oP (mouse-position))
	 (oframe (car oP))
	 (ox     (cadr oP))
	 (oy     (cddr oP)))
    (set-mouse-position frame x y)
    (tooltip-show text t)
    (set-mouse-position oframe ox oy)))

(defun stitch-show-annotation ()
  (interactive)
  (unless (boundp 'stitch-in-show-annotation-dirty-hack-marker)
    (let ((stitch-in-show-annotation-dirty-hack-marker t))
      (let ((overlays (overlays-at (point)))
	    found)
	(while overlays
	  (let ((o (car overlays)))
	    (when (overlay-get o 'stitch-annotation)
	      (stitch-tooltip-show-at-point 
	       (replace-regexp-in-string "\n$" "" (overlay-get o 'help-echo-string)
					 ))
	      (setq overlays nil))))))))

(defun stitch-insert-region-annotation (buffer start end face annotation date full-name mailing-address keywords fuzzy?)
  (with-current-buffer buffer
    (when (<= end (point-max))
      (let* ((o (make-overlay start end buffer))
	     (si (stitch-annotation-inline-format annotation
						  o
						  date
						  full-name
						  mailing-address
						  fuzzy?)))
	;; FILTER the SI length here.
	(overlay-put o 'help-echo-string si)
	;(overlay-put o 'mouse-face 'highlight)
	(overlay-put o 'face (or (and face
				      (facep face)
				      face)
				 'stitch-marker))
	;(overlay-put o 'point-entered (lambda (o n) 
	;				(stitch-show-annotation)))
	(let ((buffer-read-only nil))
	  (put-text-property start end 'point-entered
			     (lambda (o n)
			       (stitch-show-annotation)))
	  (not-modified)
	  )
	(let ((map (make-sparse-keymap "Stitch Marker")))
	  (define-key map [return] 'stitch-show-annotation)
	  (overlay-put o 'keymap map)
	  )
	;;      (overlay-put o 'display `((margin left-margin) "XXX"))
	(overlay-put o 'stitch-annotation t)
	(overlay-put o 'stitch-keywords keywords)))))

(defun stitch-insert-annotation-strict (file entry)
  (let ((region (stitch-target-get-region (stitch-klist-value entry :target)
					  file)))
    (when region
      (stitch-insert-annotation0
       ;; (stitch-klist-value e :target)
       (current-buffer)
       region
       (stitch-klist-value entry :annotation)
       (stitch-klist-value entry :date)
       (stitch-klist-value entry :full-name)
       (stitch-klist-value entry :mailing-address)
       (stitch-klist-value entry :keywords)
       nil))))

(defun stitch-insert-annotation-fuzzy (file entry)
  (setq stitch-search-region-total-total-total (1+ stitch-search-region-total-total-total))
  (unless (equal (stitch-klist-value entry :registered-as) file)
    (when
	(with-current-buffer (current-buffer) 
	  (or buffer-file-read-only
	      buffer-read-only
	      (eq major-mode 'dired-mode)
	      ))
      (let ((region 
	     (cond 
	      ((not (file-directory-p file))
	       (stitch-search-region 
		(current-buffer)
		(stitch-klist-value entry :target)))
	      ((eq major-mode 'dired-mode)
	       (stitch-target-get-region (stitch-klist-value entry :target)
					    file))
	      (t 
	       nil))))
	(when region
	    (stitch-insert-annotation0
	     ;; (stitch-klist-value e :target)
	     (current-buffer)
	     region
	     (stitch-klist-value entry :annotation)
	     (stitch-klist-value entry :date)
	     (stitch-klist-value entry :full-name)
	     (stitch-klist-value entry :mailing-address)
	     (stitch-klist-value entry :keywords)
	     (stitch-klist-value entry :registered-as)
	     ))))))

(defun stitch-insert-annotation0 (buffer region annotation date full-name mailing-address keywords fuzzy?)
  (if (eq (car region) (cadr region))
      (stitch-insert-point-annotation buffer 
				      (car region)
				      annotation date full-name mailing-address keywords fuzzy?)
    (stitch-insert-region-annotation buffer
				      (car region)
				      (cadr region)
				      (caddr region)
				      annotation date full-name mailing-address keywords fuzzy?)))

(defun stitch-insert-annotations-strict (buffer)
  (with-current-buffer buffer
    (let ((file (stitch-buffer-file-name (current-buffer))))
      (when file
	(let ((entries (gethash file stitch-annotations nil)))
	  (when (with-current-buffer (current-buffer)  
		  (or buffer-file-read-only
		      buffer-read-only
		      (eq major-mode 'dired-mode)
		      ;;
		      (eq major-mode 'diff-mode)
		      ;; t
		      ))
	    (mapc
	     (lambda (entry) 
	       (stitch-insert-annotation-strict file entry))
	     (reverse (sort (copy-list entries) 'stitch-annotation-compare)))))))))

(defun stitch-similar-directory-p (a b)
  (let* ((am (split-string a "/"))
	 (bm (split-string b "/"))
	 (al (length am))
	 (bl (length bm)))
    (and (eq al bl)
	 (> (count t (mapcar* #'equal am bm))
	    ;; Heuristic
	    (- al 3)))))

(defun stitch-insert-annotations-fuzzy (buffer)
  (prog1
      (with-current-buffer buffer
	(let ((file (stitch-buffer-file-name (current-buffer))))
	  (when file
	    (let ((entries (gethash 
			    ;; TODO: This depends on major mode.
			    (if (eq major-mode 'dired-mode)
				(file-name-nondirectory (directory-file-name file))
			      (file-name-nondirectory file))
			    stitch-annotations-fuzzy nil)))
	      (mapc
	       (lambda (entry) 
		 (when (or (not (eq major-mode 'dired-mode))
			   (stitch-similar-directory-p (stitch-klist-value entry :registered-as)
							file))
		   (stitch-insert-annotation-fuzzy file entry))
		 )
	       ;; TODO: This should be done in registration
	       (reverse (sort (copy-list entries) 'stitch-annotation-compare)))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun stitch-insert-annotations (&optional buffer)
  ;; Checking (boundp 'dirname) here is quite dirty hack.
  ;; See `dired-readin'. `dired-after-readin-hook' called twice for
  ;; each `revert-buffer'.
  (when (or (not (eq major-mode 'dired-mode))
	    (not (boundp 'dirname))
	    (boundp 'failed))
    (with-current-buffer (or buffer (current-buffer))
      (stitch-insert-annotations-strict (current-buffer))
      (stitch-insert-annotations-fuzzy (current-buffer)))))

(defun stitch-search-make-search-text (r b f)
  (let ((newline ""))
    (let ((rb (if (equal r "")
		  b
		(if (equal b "")
		    r
		  (concat r newline b)))))
      (if (equal rb "")
	  f
	(if (equal f "")
	    rb
	  (concat rb newline f))))))


(defvar stitch-search-region-total-total-total 0)
(defvar stitch-search-region-total-total 0)
(defvar stitch-search-region-total 0)
(defvar stitch-search-region-hit 0)
(defvar stitch-search-region-miss 0)
(defun stitch-search-region-reset-counter ()
  (interactive)
  (setq 
   stitch-search-region-total-total-total 0
   stitch-search-region-total-total 0
   stitch-search-region-total 0
   stitch-search-region-hit 0
   stitch-search-region-miss 0))
(defun stitch-search-region (buffer target)
  ;; TODO: Directory fuzzy insertion is not supported now.
  (setq stitch-search-region-total-total 
	(1+ stitch-search-region-total-total))
  (with-current-buffer buffer
    (when (eq (stitch-klist-value target :type) 'file)
      (let* ((point (stitch-klist-value target :point))
	     (surround (stitch-klist-value target :surround))
	     (surround-text (stitch-search-make-search-text 
			     (car surround)
			     (cadr surround)
			     (caddr surround)))
	     (extra-length (length (car surround)))
	     )
	(when surround
	  (save-excursion
	    (goto-char (point-max))
	    (let ((points (list)))
	      (save-excursion
		(setq stitch-search-region-total (1+ stitch-search-region-total))
		(if (search-backward surround-text nil t)
		    (setq stitch-search-region-hit (1+ stitch-search-region-hit))
		  (setq stitch-search-region-miss (1+ stitch-search-region-miss))
		  ))
	      (while (search-backward surround-text nil t)
		(setq points (cons (+ (point) extra-length) points)))
	      (let ((delta (point-max))
		    nearest)
		(while points
		  (when (< (abs (- point (car points))) delta)
		    (setq delta (- point (car points))
			  nearest (car points)))
		  (setq points (cdr points)))
		(when nearest
		  (list nearest nearest))))))))))
		

(defun stitch-walk-annotations (proc &optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (mapc
     (lambda (o)
       (when (overlay-get o 'stitch-annotation)
	 (funcall proc o)))
     (overlays-in (point-min)
		  (1+ (point-max))
		  ))))

(defun stitch-delete-annotations (&optional buffer)
  (stitch-walk-annotations #'delete-overlay buffer))


(defun stitch-char-shrinker (o)
  (let ((master (overlay-get o 'stitch-master-string)))
    (when master 
      (let* ((current (overlay-get o 'after-string))
	     (lcurrent (length current)))
	;; Keep 1 byte
	(when (< 1 lcurrent)
	  (overlay-put o 'after-string
		       (substring current 0 (1- lcurrent))))))))

(defun stitch-char-enlarger (o)
  (let ((master (overlay-get o 'stitch-master-string)))
    (when master
      (let* ((current (overlay-get o 'after-string))
	     (lcurrent (length current))
	     (lmaster  (length master)))
	(when (< lcurrent lmaster)
	  (overlay-put o 'after-string
		       (substring master 0 (1+ lcurrent))))))))

(defun stitch-line-shrinker (o)
  (let ((master (overlay-get o 'stitch-master-string)))
    (when master 
      (let* ((current (overlay-get o 'after-string))
	     (lcurrent (split-string current "\n"))
	     (llcurrent (length lcurrent)))
	(when (< 0 llcurrent)
	  (overlay-put o 'after-string
		       (mapconcat 
			(lambda (x) x)
			(reverse (cdr (reverse lcurrent)))
			(propertize
			 "\n"
			 ;; TODO: ??? fuzzy
			 'face 'stitch-annotation-base))))))))


(defun stitch-line-enlarger (o)
  (let ((master (overlay-get o 'stitch-master-string)))
    (when master 
      (let* ((current (overlay-get o 'after-string))
	     (lcurrent (split-string current "\n"))
	     (llcurrent (length lcurrent))
	     (lmaster (split-string master "\n"))
	     (llmaster (length lmaster)))
	(when (< llcurrent llmaster)
	  (overlay-put o 'after-string
		       (mapconcat 
			 (lambda (x) x)
			 (reverse (nthcdr (- (- llmaster llcurrent) 1) (reverse lmaster)))
			 (propertize
			  "\n"
			  ;; TODO: ??? fuzzy
			  'face 'stitch-annotation-base))))))))

(defun stitch-shrink-annotations (&optional buffer)
  (interactive)
  (stitch-walk-annotations (lambda (o) 
			     (let ((shrinker (overlay-get o 'stitch-shrinker)))
			       (if shrinker
				   (funcall shrinker o)
				 (stitch-line-shrinker o))))
			       buffer))

(defun stitch-enlarge-annotations (&optional buffer)
  (interactive)
  (stitch-walk-annotations (lambda (o) 
			     (let ((enlarger (overlay-get o 'stitch-enlarger)))
			       (if enlarger
				   (funcall enlarger o) 
				 (stitch-line-enlarger o))))
			       buffer))

(define-key global-map [(shift mouse-4)] 'stitch-shrink-annotations)
(define-key global-map [(shift mouse-5)] 'stitch-enlarge-annotations)

(define-key global-map [(hyper ?\{)] 'stitch-shrink-annotations)
(define-key global-map [(hyper ?\})] 'stitch-enlarge-annotations)


(defun stitch-reload-annotations (&optional all-buffer just-rerender)
  (interactive "P")
  
  (mapcar
   'stitch-delete-annotations
   (if all-buffer (buffer-list) (list (current-buffer))))
  (unless just-rerender
    (setq stitch-annotations (make-hash-table :test 'equal))
    (setq stitch-annotations-fuzzy (make-hash-table :test 'equal))
    (setq stitch-keywords (make-hash-table :test 'eq))
    (stitch-load-annotations))
  (mapcar
   'stitch-insert-annotations
   (if all-buffer (buffer-list) (list (current-buffer)))))

(defun stitch-load-annotation (stream file-name)
  ;; TODO start, end, and file-name are not used yet.
  (let ((start (point))
	(r (stitch-read-safely stream))
	(end   (point)))
    (cond
     ((eq (car r) 'stitch-annotation)
      (let ((target-list (mapcar
			  'stitch-target-load
			  (stitch-klist-value r :target-list)))
	    (annotation-list (mapcar
			      'stitch-annotation-load
			      (stitch-klist-value r :annotation-list)))
	    (date (stitch-klist-value r :date))
	    (full-name (stitch-klist-value r :full-name))
	    (mailing-list (stitch-klist-value r :mailing-address))
	    (keywords (stitch-klist-value r :keywords)))
	(mapc
	 (lambda (target)
	   (mapc
	      (lambda (annotation)
		  (stitch-register-annotation target
					      annotation
					      date full-name
					      mailing-list
					      keywords
					      (list file-name start end)))
	      annotation-list))
	 target-list)
	))
     ((eq (car r) 'define-keyword)
      (stitch-register-keyword (cadr r)
				(stitch-klist-value r :subject)
				(stitch-klist-value r :date)
				(stitch-klist-value r :full-name)
				(stitch-klist-value r :mailing-address)
				(stitch-klist-value r :keywords)))
     ((eq (car r) 'material)
      ;; (material FILE :keywords (KEYWORDS...))
      )
     )
    r))

(defun stitch-build-file-list (file-and-dir-list seed)
  (if (null file-and-dir-list)
      seed
    (stitch-build-file-list
     (cdr file-and-dir-list)
     (let ((file-or-dir (car file-and-dir-list)))
       (if (file-directory-p file-or-dir)
	   (stitch-build-file-list
	    (directory-files file-or-dir t ".*\\.es$")
	    seed)
	 (if (member file-or-dir seed)
	     seed
	   (cons file-or-dir seed)))))))

(defun stitch-load-annotations ()
  (mapc
   (lambda (f)
     (stitch-with-current-file f
       (goto-char (point-min))
       (while (stitch-load-annotation (current-buffer)
				       f)
	 t)
       ))
   (let ((file (expand-file-name stitch-annotation-file))
	 (file-list (stitch-build-file-list (mapcar
					      'expand-file-name
					      stitch-annotation-external-files)
					     (list))))
     (if (member file file-list)
	 ;;
	 ;; It seems that there are hash table bugs in GNU Emacs.
	 ;; So I shuffle what I'll do.
	 ;;
	 (reverse file-list)
       (cons file file-list)))))

(defun stitch-register-keyword (keyword subject date full-name mailing-address parent-keywords)
  (let ((entry (gethash keyword stitch-keywords ())))
    (puthash keyword (cons (list :subject subject
				 :date date
				 :full-name full-name
				 :mailing-address mailing-address
				 :keywords parent-keywords) entry)
	     stitch-keywords)))

(defun stitch-lookup-keyword (keyword)
  (reverse (gethash keyword stitch-keywords nil)))

(defvar stitch-toggle-annotation 1)
(defun stitch-toggle-annotation (arg)
  (interactive "P")
  (cond ((and (numberp arg) (< arg 0))
	 (setq stitch-toggle-annotation -1)
	 (mapcar
	  'stitch-delete-annotations
	  (buffer-list)))
	((and (numberp arg) (> arg 0))
	 (setq stitch-toggle-annotation 1)
	 (stitch-reload-annotations t t)
	 )
	(t
	 (stitch-toggle-annotation
	  (if (> stitch-toggle-annotation 0) -1 1)))))

;;
;; File Target Backend
;;

;; =====================================================================
;; Stolen from file `misc-func.el' by Drew Adams.
;; ---------------------------------------------------------------------
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;

;; Stolen from file `intes.el.2'
;;;###autoload
(defun stitch-current-line ()
  "Current line number of cursor."
  (+ (count-lines (point-min) (point))
     (if (= (current-column) 0) 1 0)))
;; =====================================================================
(defun stitch-safe-which-function ()
  (condition-case nil
      (which-function)
    (error nil)))
(defun stitch-current-surround (r0 r1)
  (list (save-excursion (buffer-substring-no-properties r0
					  (progn (forward-line -1) (point))))
	(buffer-substring-no-properties r0 r1)
	(save-excursion (buffer-substring-no-properties r1
					  (progn (forward-line 1) (line-end-position))))))

(defun stitch-file-target-new ()
  (let* ((func    (stitch-safe-which-function))
	 (line    (save-restriction (widen) (stitch-current-line)))
	 (surround (save-restriction (widen) (stitch-current-surround (point) (point))))
	 (target `(target :type file
			  :file ,(stitch-buffer-file-name)
			  :point ,(point)
			  :coding-system ,buffer-file-coding-system
			  :line ,line
			  :surround ,surround)))
    (if func
	(stitch-klist-append target :which-func func)
      target)))

(defun stitch-file-target-get-files (target)
  (list (stitch-klist-value target :file)))
(defun stitch-file-target-get-point (target file)
  (stitch-klist-value target :point))
(defun stitch-file-target-get-region (target file)
  (let ((p (stitch-file-target-get-point target file)))
    (list p p)))
(defun stitch-file-target-get-label (target file)
  (let ((f (stitch-klist-value target :which-func)))
    (if f
	(format "Function: %s" f)
      (format "Point: %s" (stitch-klist-value target :point)))))
(defun stitch-file-target-save-form (target)
  target)
(defun stitch-file-target-load (es)
  es)
(defun stitch-file-target-jump (target file)
  (when file
    (find-file file)
    (goto-char (stitch-file-target-get-point target file))))

(stitch-register-taregt-handlers
 'file
 '(:make      stitch-file-target-new
   :load      stitch-file-target-load
   :get-files stitch-file-target-get-files
   :get-point stitch-file-target-get-point
   :get-region stitch-file-target-get-region
   :get-label stitch-file-target-get-label
   :save-form stitch-file-target-save-form
   :jump      stitch-file-target-jump))

;;
;; Region Target Backend 
;;
(defun stitch-region-target-new ()
  (let ((b (region-beginning))
	(e (region-end)))
    (when (eq b e)
      (error "the region size is 0"))
    (let* ((func (stitch-safe-which-function))
	   (line (save-restriction (widen) (stitch-current-line)))
	   (surround (stitch-current-surround b e))
	   (target `(target :type region
			    :subtype file
			    :file ,(stitch-buffer-file-name)
			    :region (,b ,e)
			    :coding-system ,buffer-file-coding-system
			    :line ,line
			    :surround ,surround
			    :face ,(read-face-name "Face" 'stitch-marker))))
      (if func
	  (stitch-klist-append target :which-func func)
	target))))

(defun stitch-region-target-get-files (target)
  (list (stitch-klist-value target :file)))
(defun stitch-region-target-get-point (target file)
  (car (stitch-klist-value target :region)))
(defun stitch-region-target-get-region (target file)
  (reverse
   (cons (stitch-klist-value target :face)
	 (reverse (stitch-klist-value target :region)))))
;; TODO
(defun stitch-region-target-get-label (target file)
  (apply 'format "Function: %s\nRegion: %s - %s" 
	 (stitch-klist-value target :which-func)
	 (stitch-klist-value target :region)))
(defun stitch-region-target-save-form (target)
  target)
(defun stitch-region-target-load (es)
  es)
(defun stitch-region-target-jump (target file)
  (when file
    (find-file file)
    (goto-char (stitch-region-target-get-point target file))))

(stitch-register-taregt-handlers
 'region
 '(:make      stitch-region-target-new
   :load      stitch-region-target-load
   :get-files stitch-region-target-get-files
   :get-point stitch-region-target-get-point
   :get-region stitch-region-target-get-region
   :get-label stitch-region-target-get-label
   :save-form stitch-region-target-save-form
   :jump      stitch-region-target-jump))				  

;;
;; Directory Target Backend
;;
(defun stitch-directory-target-new ()
  `(target :type directory
	   :directory ,(expand-file-name (stitch-buffer-file-name))
	   :item ,(dired-get-filename t t))
  ;; ??? coding system
  )
(defun stitch-directory-target-get-files (target)
  (list (stitch-klist-value target :directory)))
;; (defun stitch-directory-target-get-point (target directory)

;;   (let ((item (stitch-klist-value target :item)))
;;     (if (and (equal (stitch-buffer-file-name) directory)
;; 	     (eq major-mode 'dired-mode))
;; 	(let ((absolute-item (concat (file-name-as-directory directory) item)))
;; 	  (condition-case nil
;; 	      (save-excursion
;; 		(dired-goto-file absolute-item)
;; 		(beginning-of-line)
;; 		(point))
;; 	      (error 0)))
;;       0)))

(defun stitch-directory-target-get-point (target directory)

  (let* ((item (stitch-klist-value target :item))
	 (dirbuf (dired-buffers-for-dir directory))
	 (absolute-item (concat (file-name-as-directory directory) item)))
    (if (car dirbuf)
	(with-current-buffer (car dirbuf)
	  (condition-case nil
	      (save-excursion
		(if (dired-goto-file absolute-item)
		    (progn
		      (beginning-of-line)
		      (point))
		  nil))
	    (error 0)))
      0)))

(defun stitch-directory-target-get-region (target directory)
  (let ((p (stitch-directory-target-get-point target directory)))
    (if p
	(list p p)
      nil)))

(defun stitch-directory-target-get-label (target directory)
  (format "Item: %s" (stitch-klist-value target :item)))

(defun stitch-directory-target-save-form (target)
  `(target :type  ,(stitch-klist-value target :type)
	   :directory  ,(stitch-klist-value target :directory)
	   :item ,(stitch-klist-value target :item)))
(defun stitch-directory-target-load (es)
  es)

(defun stitch-directory-target-jump (target file)
  (when (and file
	     (file-directory-p file))
    (dired file)
    (goto-char (stitch-directory-target-get-point target file))))

(stitch-register-taregt-handlers
 'directory
 '(:make      stitch-directory-target-new
   :load      stitch-directory-target-load
   :get-files stitch-directory-target-get-files
   :get-point stitch-directory-target-get-point
   :get-region stitch-directory-target-get-region
   :get-label stitch-directory-target-get-label
   :save-form stitch-directory-target-save-form
   :jump      stitch-directory-target-jump))


(defun stitch-generic-annotation-load (es)
  es)
(defun stitch-generic-annotation-save-form (annotation)
  `(annotation :type ,(stitch-klist-value annotation :type)
	       :data  ,(stitch-klist-value annotation :data)))

;;
;; Annotation Backend
;;
(defun stitch-oneline-annotation-new (commit-func commit-args)
  (funcall commit-func
	   `(anntation :type oneline
		       :data ,(read-from-minibuffer "Annotation: "))
	   commit-args
	   (stitch-read-keywords "Commit with" t)
	   current-prefix-arg))

(defun stitch-make-registered-as-line (fuzzy?)
  (if fuzzy? 
      (concat "@" (propertize fuzzy? 'face 'stitch-annotation-registered-as-line) "\n")
    ""))
(defun stitch-oneline-annotation-inline-format (annotation
						overlay
						date full-name mailing-address
						fuzzy?)
  (let ((pos (overlay-start overlay)))
    (let* ((b (char-before pos)))
      (concat ;; TODO
	      (stitch-make-annotation-header date full-name mailing-address fuzzy?)
	      ;;
	      (propertize
	       (stitch-klist-value annotation :data)
	       'face (if fuzzy? 'stitch-annotation-fuzzy 'stitch-annotation-body))
	      (stitch-make-registered-as-line fuzzy?)
	      (propertize
	       "\n"
	       'face (if fuzzy? 'stitch-annotation-fuzzy 'stitch-annotation-base))))))

(defun stitch-oneline-annotation-list-format (annotation)
  (stitch-klist-value annotation :data))

(stitch-register-annotation-handler
 'oneline
 '(:make          stitch-oneline-annotation-new
   :load          stitch-generic-annotation-load
   :save-form     stitch-generic-annotation-save-form
   :inline-format stitch-oneline-annotation-inline-format
   :list-format   stitch-oneline-annotation-list-format
   ))

(defvar stitch-edit-annotation-commit-func nil)
(defvar stitch-edit-annotation-commit-args nil)
(defvar stitch-edit-annotation-window-configuration nil)
(defvar stitch-edit-annotation-make-data nil)
(defvar stitch-edit-annotation-make-post-data nil)
(defun stitch-edit-annotation-new-0 (bname header commit-func commit-args mode
					    make-data make-post-data)
  (let ((wc (current-window-configuration))
	(b  (get-buffer-create bname)))
    (with-current-buffer b
      (funcall mode)
      (set (make-variable-buffer-local
	    'stitch-edit-annotation-commit-func) commit-func)
      (set (make-variable-buffer-local
	    'stitch-edit-annotation-commit-args) commit-args)
      (set (make-variable-buffer-local
	    'stitch-edit-annotation-window-configuration) wc)
      (set (make-variable-buffer-local
	    'stitch-edit-annotation-make-data) make-data)
      (set (make-variable-buffer-local
	    'stitch-edit-annotation-make-post-data) make-post-data)
      (let ((o (make-overlay (point-min) (point-min))))
	;; TODO Remove older overlays
	(overlay-put o 'stitch-edit-annotation-header t)
	(overlay-put o 'before-string header)
	(local-set-key "\C-c\C-c"
		       (lambda (prefix) (interactive "P")
			 (funcall
			  stitch-edit-annotation-commit-func
			  (funcall stitch-edit-annotation-make-data
				   (buffer-substring-no-properties
				    (point-min)
				    (point-max)))
			  stitch-edit-annotation-commit-args
			  (funcall stitch-edit-annotation-make-post-data
				   stitch-edit-annotation-commit-args)
			  prefix)
			 (let ((abuffer (current-buffer))
			       (obuffer (stitch-klist-value
					 stitch-edit-annotation-commit-args
					 :buffer))
			       (opoint  (stitch-klist-value
					 stitch-edit-annotation-commit-args
					 :point)))
			   (set-window-configuration
			    stitch-edit-annotation-window-configuration)
			   (when (buffer-live-p (get-buffer obuffer))
			     (set-buffer obuffer)
			     (goto-char opoint))
			   (kill-buffer abuffer))
			 ))
	(local-set-key "\C-c\C-l" (lambda () (interactive)
				    (set-window-point
				     (display-buffer
				      (stitch-klist-value stitch-edit-annotation-commit-args :buffer))
				     (stitch-klist-value stitch-edit-annotation-commit-args :point))
				    ))
	))
    (pop-to-buffer b)))

(defun stitch-edit-annotation-new (commit-func commit-args mode etype)
  (let* ((buf  (stitch-klist-value commit-args :buffer))
	 (bname (buffer-name buf))
	 (dirp (with-current-buffer buf (eq major-mode 'dired-mode)))
	 (elt (if dirp 
		  (with-current-buffer buf 
		    (goto-char (stitch-klist-value commit-args :point))
		    (dired-get-filename t t))
		(stitch-klist-value commit-args :point)
		))
	 )
    (stitch-edit-annotation-new-0 (format "*Annotation<%s:%s>*"
					  bname
					  elt
					  )
				  (concat
				   (propertize
				    (format (if dirp
						    "Directory: %s\nItem: %s\nKeywords: \n"
						  "File: %s\nPoint: %d\nKeywords: \n")
						bname
						elt
						)
				    'face 'stitch-annotation-edit-header
				    'mouse-face 'highlight)
				   "----\n")
				  commit-func commit-args mode
				  `(lambda (bstring)
				     (list 'annotation :type ',etype
					   :data bstring))
				  (lambda (commit-args) 
				    (stitch-read-keywords nil t)))))

(defun stitch-text-annotation-new (commit-func commit-args)
  (stitch-edit-annotation-new commit-func commit-args 'text-mode 'text))

(defun stitch-text-annotation-inline-format (annotation
					     overlay
					     date full-name mailing-address
					     fuzzy?)
  (let ((pos (overlay-start overlay)))
    (let* ((b (char-before pos))
	   (bn (or (eq b ?\n) (not b)))
	   (an (eq (char-after pos) ?\n)))
      (concat (propertize
	       (concat (if (eq major-mode 'dired-mode) "" "\n")
		       (if bn "" "\n" ))
	       'face (if fuzzy? 'stitch-annotation-fuzzy 'stitch-annotation-base))
	      (stitch-make-annotation-header date full-name mailing-address fuzzy?)
	      (propertize
	       (stitch-klist-value annotation :data)
	       'face (if fuzzy? 'stitch-annotation-fuzzy 'stitch-annotation-body))
	      (propertize
	       (concat
		(if (eq major-mode 'dired-mode) "" "\n")
		(if an "" "\n" ))
	       'face (if fuzzy? 'stitch-annotation-fuzzy 'stitch-annotation-base))
	      (stitch-make-registered-as-line fuzzy?)))))

(defun stitch-text-annotation-list-format (annotation)
  (stitch-klist-value annotation :data))

(stitch-register-annotation-handler
 'text
 '(:make          stitch-text-annotation-new
		  ;; TODO
   :load          stitch-generic-annotation-load
   :save-form     stitch-generic-annotation-save-form
   :inline-format stitch-text-annotation-inline-format
   :list-format   stitch-text-annotation-list-format))

;;
;; Graphviz Common
;;
(defun stitch-generic-image-annotation-inline-format (image
						      footer
						      overlay
						      date full-name mailing-address
						      fuzzy?)
  (let ((pos (overlay-start overlay)))
    (let* ((b (char-before pos))
	   (bn (or (eq b ?\n) (not b)))
	   (an (eq (char-after pos) ?\n)))
      (concat (propertize (concat "\n" (if bn "" "\n" )) 
			  'face (if fuzzy? 'stitch-annotation-fuzzy 'stitch-annotation-base))
	      (stitch-make-annotation-header date full-name mailing-address fuzzy?)
	      (propertize
	       " "
	       'display image)
	      ;;
	      (propertize
	       (concat
		"\n"
		(stitch-make-registered-as-line fuzzy?)
		(or footer "")
		(if an "" "\n" ))
	       'face (if fuzzy? 'stitch-annotation-fuzzy 'stitch-annotation-base))))))

(defun stitch-generic-image-annotation-list-format (image footer)
  (concat "\n"
	  (propertize
	   " "
	   'display image)
	  "\n"
	  (if footer
	      (concat footer "\n") "")
	  ))

(defun stitch-graphviz-annotation-inline-format (cmd
						 annotation
						 overlay
						 date full-name mailing-address
						 fuzzy?)
  (let ((image (stitch-graphviz-create-image (stitch-klist-value annotation :data)
						       cmd)))
    (stitch-generic-image-annotation-inline-format image
						   nil
						   overlay
						   date
						   full-name
						   mailing-address
						   fuzzy?)))

(defun stitch-graphviz-annotation-list-format (annotation cmd)
  (stitch-generic-image-annotation-list-format 
   (stitch-graphviz-create-image (stitch-klist-value annotation :data)
				 cmd)
   nil))

(defun stitch-graphviz-make-command-line (cmd dotfile pngfile)
  (if (stringp cmd)
      (format "%s -T png %s > %s" cmd dotfile pngfile)
    (funcall cmd dotfile pngfile)))
(defun stitch-graphviz-create-image (code cmd)
  (save-excursion
    (let* ((dotfile (make-temp-file "s-a" nil ".dot"))
	   (pngfile  (make-temp-file "s-a" nil ".png")))
      (with-temp-buffer
	(insert code)
	(write-file dotfile)
	)
    (let ((status (shell-command
		   (stitch-graphviz-make-command-line cmd dotfile pngfile))))
      ;;
      (let ((i (create-image pngfile)))
	(delete-file dotfile)
;;	(delete-file pngfile)
	i)))))

;;
;; Graphviz/Dot
;;
(defmacro define-graphviz (cmd)
  ;;
  `(progn
     (defun ,(intern (format "stitch-%S-annotation-new" cmd)) (commit-func commit-args)
       (stitch-edit-annotation-new commit-func commit-args
				    (quote graphviz-dot-mode)
				    (quote ,(intern (format "graphviz-%S" cmd)))))
     ;;
     (defun ,(intern (format "stitch-%S-annotation-inline-format" cmd)) (annotation
									 overlay
									 date full-name mailing-address
									 fuzzy?)
       (stitch-graphviz-annotation-inline-format ,(symbol-name cmd)
						  annotation
						  overlay
						  date full-name mailing-address
						  fuzzy?))
     (defun ,(intern (format "stitch-%S-annotation-list-format" cmd)) (annotation)
       (stitch-graphviz-annotation-list-format annotation ,(symbol-name cmd)))
     (stitch-register-annotation-handler
      (quote ,(intern (format "graphviz-%S" cmd)))
      (quote (:make          ,(intern (format "stitch-%S-annotation-new" cmd))
	      :load          stitch-generic-annotation-load
	      :save-form     stitch-generic-annotation-save-form
	      :inline-format ,(intern (format "stitch-%S-annotation-inline-format" cmd))
	      ;; TODO
	      :list-format   ,(intern (format "stitch-%S-annotation-list-format" cmd))
	      )))))
(define-graphviz dot)
(define-graphviz neato)
(define-graphviz twopi)
(define-graphviz circo)
(define-graphviz fdp)


;;
;; Mscgen
;;
(defun stitch-mscgen-make-command-line (dotfile pngfile)
  (format "mscgen -T png -i %s -o %s" dotfile pngfile))
(defun stitch-mscgen-annotation-new (commit-func commit-args)
  (stitch-edit-annotation-new commit-func commit-args 'graphviz-dot-mode 'mscgen))
(defun stitch-mscgen-annotation-inline-format (annotation
					       overlay
					       date full-name mailing-address
					       fuzzy?)
  (stitch-graphviz-annotation-inline-format
   'stitch-mscgen-make-command-line
   annotation
   overlay
   date full-name mailing-address
   fuzzy?))

(defun stitch-mscgen-annotation-list-format (annotation)
  (stitch-graphviz-annotation-list-format annotation
					   'stitch-mscgen-make-command-line))

(stitch-register-annotation-handler
 'mscgen
 '(:make          stitch-mscgen-annotation-new
   :load          stitch-generic-annotation-load
   :save-form     stitch-generic-annotation-save-form
   :inline-format stitch-mscgen-annotation-inline-format
   :list-format   stitch-mscgen-annotation-list-format))

;;
;; WebImage
;;
(defun stitch-webimage-annotation-new (commit-func commit-args)
  (let* ((url (read-from-minibuffer "URL: "))
	 (md5 (stitch-webimage-make-cache-name url))
	 (status 
	  (or (file-exists-p md5)
	      (stitch-webimage-annotation-retrieve url md5))))
    (if status
	(funcall commit-func
		 `(annotation :type webimage
			      :data ,url)
		 commit-args
		 (cons 'webimage (stitch-read-keywords "Commit with" t))
		 current-prefix-arg)
      (error "cannot return retrieve: %s" url))))


(defconst stitch-webimage-cache-dir (let ((d (expand-file-name "~/.stitch-webimage")))
				      (or (file-exists-p d)
					  (make-directory d))
				      d))

(defun stitch-webimage-make-command-line (url output)
  (format "curl --output %s %s" output url))

(defun stitch-webimage-annotation-retrieve (url output)
  (let ((status (shell-command (stitch-webimage-make-command-line url output))))
    (if (eq status 0)
	t
      nil)))

(defun stitch-webimage-make-cache-name (url)
  (expand-file-name (format "%s.%s"
			    (md5 url) 
			    (file-name-extension url)) 
		    stitch-webimage-cache-dir))

(defun stitch-webimage-create-image (annotation)
  (let* ((url (stitch-klist-value annotation :data))
	 (md5 (stitch-webimage-make-cache-name url))
	 (file (if (file-exists-p md5)
		   md5
		 (if (stitch-webimage-annotation-retrieve url md5)
		     md5
		   nil))))
    (if file
	(create-image file)
      nil)))

(defun stitch-webimage-annotation-inline-format (annotation
						 overlay
						 date full-name mailing-address
						 fuzzy?)
  (let ((i (stitch-webimage-create-image annotation)))
    (when i
      (stitch-generic-image-annotation-inline-format i
						     (stitch-klist-value annotation :data)
						     overlay
						     date
						     full-name
						     mailing-address
						     fuzzy?))))

(defun stitch-webimage-annotation-list-format (annotation)
  (let ((i (stitch-webimage-create-image annotation)))
    (when i 
      (stitch-generic-image-annotation-list-format i 
						   (stitch-klist-value annotation :data)))))

(stitch-register-annotation-handler
 'webimage
 '(:make          stitch-webimage-annotation-new
   :load          stitch-generic-annotation-load
   :save-form     stitch-generic-annotation-save-form
   :inline-format stitch-webimage-annotation-inline-format
   :list-format   stitch-webimage-annotation-list-format))

;;
;; Table rendering with tbl
;;
;; ------------------------------------------------
;; .TS
;; l l
;; _ _
;; l l.
;; \fIOption\fR	\fITreatment\fR
;; \fB--beep-after\fP	ignored
;; \fB--guage\fP	mapped to \fB--gauge\fP
;; .TE
;; ------------------------------------------------
(defun stitch-groff-annotation-new (commit-func commit-args)
  (stitch-edit-annotation-new commit-func commit-args 'nroff-mode 'groff))

(defun stitch-groff-make-gs-command (res)
  (format
   "gs -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=png256 -r%dx%d -sOutputFile=- -q -"
   res
   res))

(defun stitch-groff-make-command-line (dotfile pngfile)
  (format
   "cat %s | groff -t -T ps - | %s | convert -trim - %s"
   dotfile
   (stitch-groff-make-gs-command 150)
   pngfile))

(defun stitch-groff-annotation-inline-format (annotation
					      overlay
					      date full-name mailing-address
					      fuzzy?)
  (stitch-graphviz-annotation-inline-format
   'stitch-groff-make-command-line
   annotation
   overlay
   date full-name mailing-address
   fuzzy?))

(defun stitch-groff-annotation-list-format (annotation)
  (stitch-graphviz-annotation-list-format
   annotation
   'stitch-groff-make-command-line))

(stitch-register-annotation-handler
 'groff
 '(:make          stitch-groff-annotation-new
		  ;; TODO
   :load          stitch-generic-annotation-load
   :save-form     stitch-generic-annotation-save-form
   :inline-format stitch-groff-annotation-inline-format
   :list-format   stitch-groff-annotation-list-format))

;;
;; Listing and reporting
;;
(defun stitch-list-annotation-about-current-file ()
  (interactive)
  (let* ((target-file (stitch-buffer-file-name))
	 (target-file-non-directory (file-name-nondirectory target-file)))
    (stitch-list-annotation-with-filter
     (format "*List Annotations: %s*" (buffer-name))
     (lambda (k e) (or (string= 
			k 
			target-file)
		       (string= 
			(file-name-nondirectory k)
			target-file-non-directory)))
     t
     t)))

(defun stitch-list-annotation-about-keyword (keywords buffer-or-name need-erasing)
  (let ((and-set nil))
    (fset 'or-set (lambda (s1 s2)
		     (if (car s1)
			 (or (member (car s1) s2)
			      (or-set (cdr s1) s2))
		       nil)))
    (stitch-list-annotation-with-filter buffer-or-name
					 (lambda (k e)
					   (if keywords
					       (or-set
						keywords
						(stitch-klist-value e :keywords))
					     t))
					 need-erasing
					 (if (eq (length keywords) 1) nil t))))
					     

(defun stitch-list-annotation (all-filter)
  (interactive "P")
  (let* ((keywords (unless all-filter
		       (stitch-read-keywords "List annotations for" t)
		       ))
	 (bname (if keywords
		    (format "*List Annotations/%S*" keywords)
		  "*List ALL Annotations*"
		  )))
    (stitch-list-annotation-about-keyword keywords
					   bname
					   t)))

(defvar stitch-list-annotation-window-config nil)
(defun stitch-list-annotation-with-filter (buffer-or-name filter need-erasing show-keyword)
  (let ((b (if (bufferp buffer-or-name)
	       buffer-or-name
	     (get-buffer-create buffer-or-name))))
    (with-current-buffer b
      (setq buffer-read-only t)
      (set (make-variable-buffer-local
	    'stitch-list-annotation-window-config) (current-window-configuration))
      (let ((filter-annotations (list))
	    (buffer-read-only nil))
	(when need-erasing
	  (erase-buffer))
	(maphash (lambda (k v)
		   (mapc
		    (lambda (e)
		      (when (funcall filter k e)
			(setq filter-annotations
			      (cons (list k e) filter-annotations))))
		    v))
		 stitch-annotations)
	(mapcar
	 (lambda (l)
	   (let ((k (nth 0 l))
		 (e (nth 1 l)))
	     (insert
	      "\n"
	      (concat (stitch-make-annotation-header
		       (stitch-klist-value e :date)
		       (stitch-klist-value e :full-name)
		       (stitch-klist-value e :mailing-address)
		       nil)
		      (let ((file (file-name-nondirectory k)))
			(propertize (concat
				     (if (equal "" file)
					 ""
				       (concat "File: " (file-name-nondirectory k) "\n"))
				     "Directory: " (file-name-directory k) "\n"
				     (stitch-target-get-label
				      (stitch-klist-value e :target)
				      k) "\n"
				     (format "Home: %S\n" (stitch-klist-value e :annotation-home))
				     (if show-keyword
					 (format "Keywords: %S\n"
						 (stitch-klist-value e :keywords))
				       ""))
				    'face 'stitch-annotation-base
				    'mouse-face 'highlight
				    'stitch-file   k
				    'stitch-target (stitch-klist-value e :target)
				    'stitch-home   (stitch-klist-value e :annotation-home)))
		      ))
	     ;;
	     (insert (propertize (stitch-annotation-list-format
				  (stitch-klist-value e :annotation))
				 'stitch-file   k
				 'stitch-target (stitch-klist-value e :target)
				 'stitch-home   (stitch-klist-value e :annotation-home)))
	     (insert "\n")
	     (insert "\n")
	     ))
	 (sort (copy-list filter-annotations) (lambda (a1 a2)
						(stitch-annotation-compare (nth 1 a1)
									   (nth 1 a2)))))

	(local-set-key [return]  'stitch-list-jump-to-target)
	(local-set-key [(shift return)]  'stitch-list-jump-to-home)
	(local-set-key [mouse-2] 'stitch-list-jump-to-target-with-mouse)
	(goto-char (point-min))))
    (pop-to-buffer b)))

(defun stitch-list-jump-to-target-with-mouse (event)
  (interactive "e")
  (save-excursion
    (set-buffer (window-buffer (posn-window (event-end event))))
    (save-excursion
      (goto-char (posn-point (event-end event)))
      (stitch-list-jump-to-target))))

(defun stitch-list-jump-to-target ()
  (interactive)
  (let ((file   (get-text-property (point) 'stitch-file))
	(target (get-text-property (point) 'stitch-target)))
    (when stitch-list-annotation-window-config
      (set-window-configuration stitch-list-annotation-window-config))
    (stitch-target-jump target file)
    ))

(defun stitch-home-jump (home)
  (when (find-file (car home))
    (goto-char (cadr home))
    (search-forward "(" nil nil)))

(defun stitch-list-jump-to-home ()
  (interactive)
  (let ((home (get-text-property (point) 'stitch-home)))
    (when stitch-list-annotation-window-config
      (set-window-configuration stitch-list-annotation-window-config))
    (stitch-home-jump home)))

(defun stitch-list-files-annotate-with-keyword (keyword)
  (interactive (list (stitch-read-keywords "List Annotations in This File for" nil)))
  (let* ((key (car keyword))
	 (b (get-buffer-create (format "*Files annotated by: %S*" key)))
	 (files (list)))
    (with-current-buffer b
      (setq buffer-read-only t)
      (let ((buffer-read-only nil))
	(erase-buffer)
	(maphash
	 (lambda (k v)
	   (mapc
	    (lambda (e) 
	      (when (member key (stitch-klist-value e :keywords))
		(let ((a (assoc k files)))
		  (if a
		      (setcdr a (1+ (cdr a)))
		    (setq files (cons (cons k 1) files))))))
	    v))
	 stitch-annotations)
	(mapc
	 (lambda (f)
	   (let ((b (point)))
	     (insert (format "[%3d] %s\n"
			     (cdr f) (file-name-nondirectory (car f))))
	     (put-text-property b (point) 'mouse-face 'highlight)
	     (insert (format "      %s\n" 
			     ;(file-name-directory (car f))
			     (car f)
			     ))
	     ))
	 (sort (copy-list files)
	       (lambda (a b)
		 (> (cdr a) (cdr b)))))
	(goto-char (point-min))
	(require 'ffap)
	(local-set-key [return] 'ffap)
	))
    (pop-to-buffer b)))

(defun stitch-save-keyword (keyword subject date full-name mailing-address parent-keywords)
  (stitch-with-current-file stitch-annotation-file
    (goto-char (point-max))
    (insert (format "%S\n" (list 'define-keyword
				 keyword
				 :version 0
				 :keywords parent-keywords
				 :subject subject
				 :date date
				 :full-name full-name
				 :mailing-address mailing-address
				 )))
    (save-buffer)
    ))


(defun stitch-commit-keyword (keyword subject parent-keywords)
  (let ((date (current-time-string))
	(full-name (stitch-get-user-full-name))
	(mailing-address (stitch-get-user-mailing-address)))
    (stitch-save-keyword     keyword
			      subject
			      date
			      full-name
			      mailing-address
			      parent-keywords)
    (stitch-register-keyword keyword
			      subject
			      date
			      full-name
			      mailing-address
			      parent-keywords)))

(defun stitch-edit-meta-new (commit-func commit-args mode etype)
  (stitch-edit-annotation-new-0 (format "*Meta Annotation: %S*"
					 (stitch-klist-value commit-args :keyword))
				 (concat
				  (propertize
				   (format "Keyword: %S\n" (stitch-klist-value
							    commit-args
							    :keyword))
				   'face 'stitch-annotation-edit-header)
				  "----\n")
				 commit-func
				 commit-args mode
				 (lambda (bstring) bstring)
				 (lambda (commit-args) (stitch-klist-value
							    commit-args
							    :keyword))))

(defun stitch-annotate-meta (keyword)
  (interactive (stitch-read-keywords "Meta Annotation" nil))
  (stitch-edit-meta-new (lambda (data args post-data prefix)
				   (stitch-commit-keyword
				    (stitch-klist-value args :keyword)
				    data
				    post-data))
			 `(:keyword ,keyword
			   :point ,(point)
			   :buffer ,(current-buffer))
			 'text-mode nil))

(defun stitch-report-about-keyword (keywords)
  (interactive (list (stitch-read-keywords "Make Report for" nil)))
  (let* ((key (car keywords))
	 (b (get-buffer-create (format "*Report: %S*" key)))
	 (kentries (stitch-lookup-keyword key)))
    (with-current-buffer b
      (let ((buffer-read-only nil))
	(erase-buffer)
	(mapc
	 (lambda (e)
	   (insert "\n")
	   (let ((stitch-annotation-inline-show-header t))
	     (insert (stitch-make-annotation-header
		      (stitch-klist-value e :date)
		      (stitch-klist-value e :full-name)
		      (stitch-klist-value e :mailing-address)
		      nil)))
	   (let ((p (point)))
	     (insert "\n")
	     (insert (stitch-klist-value e :subject))
	     (insert "\n")
	     (insert "\n")
	     (put-text-property p (point) 'face 'stitch-annotation-summary-title)
	     ;(put-text-property p (point) 'mouse-face 'highlight)
	     ))
	 kentries)))
    (when key
      (stitch-list-annotation-about-keyword (list key)
					     b
					     nil))))

(defun stitch-find-annotation-file ()
  (interactive)
  (find-file stitch-annotation-file)
  (goto-char (point-max)))

(stitch-reload-annotations t)

(add-hook (if (boundp 'find-file-hook) 'find-file-hook 'find-file-hooks)
	  'stitch-insert-annotations)
(add-hook 'rfc-article-mode-hook
	  'stitch-insert-annotations)
(add-hook 'rfc-index-mode-hook
	  'stitch-insert-annotations)

(add-hook 'dired-before-readin-hook 'stitch-delete-annotations)
(add-hook 'dired-after-readin-hook 'stitch-insert-annotations)
(add-hook 'before-revert-hook 'stitch-delete-annotations)
;;
(define-key ctl-x-4-map  "A"   'stitch-annotate-text)

(define-key ctl-x-map    "AA"  'stitch-annotate)
(define-key ctl-x-map    "A "  'stitch-draw-marker)

(define-key ctl-x-map    "AL"  'stitch-list-annotation)
(define-key ctl-x-map    "AB"  'stitch-list-files-annotate-with-keyword)
(define-key ctl-x-map    "AF"  'stitch-find-annotation-file)
(define-key ctl-x-map    "AK"  'stitch-report-about-keyword)
(define-key ctl-x-map    "AO"  'stitch-annotate-meta)
(define-key ctl-x-map    "AT"  'stitch-annotation-toggle-show-header)
;;
(define-key ctl-x-map    "An"  'stitch-next-annotation)
(define-key ctl-x-map    "Ap"  'stitch-previous-annotation)
(define-key ctl-x-map    "Al"  'stitch-list-annotation-about-current-file)
(define-key ctl-x-map    "Ag"  'stitch-reload-annotations)
(define-key ctl-x-map    "At"  'stitch-toggle-annotation)

;;
(defvar stitch-menu (make-sparse-keymap "Stitch"))
(define-key-after global-map [menu-bar stitch] (cons "Stitch"stitch-menu))
(define-key-after stitch-menu [make-text-memo]
  '(menu-item "Make Text Memorandum..." stitch-annotate-text))
(define-key-after stitch-menu [make-generic-memo]
  '(menu-item "Make Generic Memorandum..." stitch-annotate))

(define-key-after stitch-menu [separator-0] '("--"))
(define-key-after stitch-menu [list-memo]
  '(menu-item "List Memorandum..." stitch-list-annotation))

(define-key-after stitch-menu [prev-memo]
  '(menu-item "Previous Memorandum" stitch-previous-annotation))
(define-key-after stitch-menu [next-memo]
  '(menu-item "Next Memorandum" stitch-next-annotation))

(define-key-after stitch-menu [toggle-hide/show-memo]
  '(menu-item "Toggle Hide/Show Memorandums" stitch-toggle-annotation))
(define-key-after stitch-menu [separator-1] '("--"))
(define-key-after stitch-menu [reload-memos]
  '(menu-item "Reload Memorandums" stitch-reload-annotations))
(define-key-after stitch-menu [eidt-memo-file]
  '(menu-item "Edit Memorandums File" stitch-find-annotation-file))

(define-key-after stitch-menu [separator-2] '("--"))
(define-key-after stitch-menu [make-meta-memo]
  '(menu-item "Make Memorandum for Memorandum..." stitch-annotate-meta))
(define-key-after stitch-menu [report]
  '(menu-item "Report about keyword..." stitch-report-about-keyword))

;;
;; Navigation
;;
(defun stitch-next-annotation ()
  (interactive)
  (goto-char (next-overlay-change (point)))
  (while (and (not (eobp))
	      (not (member t (mapcar
			      (lambda (o)
				(overlay-get o 'stitch-annotation))
			      (overlays-in (point) (1+ (point)))))))
    (goto-char (next-overlay-change (point)))))

(defun stitch-previous-annotation ()
  (interactive)
  (goto-char (previous-overlay-change (point)))
  (while (and (not (bobp))
	      (not (member t (mapcar
			      (lambda (o)
				(overlay-get o 'stitch-annotation))
			      (overlays-in (point) (1+ (point)))))))
    (goto-char (previous-overlay-change (point)))))

(defvar stitch-annotation-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c4A"    'stitch-annotate-text)
    (define-key map "\C-ca"     'stitch-annotate)
    (define-key map "\C-cA"     'stitch-annotate-text)
    (define-key map "\C-cl"     'stitch-list-annotation-about-current-file)
    (define-key map "\C-cL"     'stitch-list-annotation)
    (define-key map "\C-ck"     'stitch-report-about-keyword)
    (define-key map "\C-c\C-n"  'stitch-next-annotation)
    (define-key map "\C-c\C-p"  'stitch-previous-annotation)
    map))

(define-minor-mode stitch-annotation-mode
  "Toggle activating and deactivating stitch-annotation related key map."
  :group 'stitch
  :lighter " Stitch")

(provide 'stitch)
