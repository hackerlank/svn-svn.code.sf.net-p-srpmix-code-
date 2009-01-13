;;; weave.el --- your source, my annotation

;; Copyright (C) 2007, 2008, 2009 Red Hat, Inc.
;; Copyright (C) 2007, 2008, 2009 Masatake YAMATO

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
;; file. Emacs weaves your annotations and the source file into a buffer
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
;; twopi or mscgen) and aweave the result png image into the buffer.

;; Not only file but also dired buffers are supported. You can make
;; annotations even on files and sub-directories in a directory opened
;; by dired. This is helpful if you want to explain a directory
;; structure in a package.

;; You can put single annotation to multiple place with emacs register
;; facility. If you modify the original annotation, the all weaved
;; annotations are updated.

;; Restriction
;; -----------
;; The source file should be not be changed; the places where
;; annotations are weaved are represented in the (point) of buffer. 
;; So if the source code is changed, the annotations are not weaved
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

;; weave annotation format
;; -------------------------

;; ANNOTATION
;; ==========
;; (weave-annotation :version 0
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
;; (target :type file :file PATH :point P [:which-func FUNCTION] [:line LINE])
;; (target :type directory :directory PATH :item FILE-or-SUBDIR)
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

(defgroup weave nil
  "Tool to weave your annotation into source code"
  :group 'tools
  :prefix "weave-")

(defface weave-annotation-base
  '((((background light)) 
     (:background "gray80"))
    (((background dark)) 
     (:background "gray20")))
  "Base face used to highlight anntations in source code."
  :group 'weave)

(defface weave-annotation-date
  '((t (:inherit (change-log-date weave-annotation-base))))
  "Face used to highlight date in anntations."
  :group 'weave)

(defface weave-annotation-body
  '((t (:inherit (font-lock-comment-face weave-annotation-base))))
  "Face used to highlight anntation body."
  :group 'weave)

(defface weave-annotation-email
  '((t (:inherit (change-log-email weave-annotation-base))))
  "Face used to highlight email addresses in anntations."
  :group 'weave)

(defface weave-annotation-name
  '((t (:inherit (change-log-name weave-annotation-base))))
  "Face used to highlight full names in anntations."
  :group 'weave)

(defface weave-annotation-edit-header
  '((t (:inherit (font-lock-comment-face weave-annotation-base))))
  "Face used to highlight the header of annotation editing buffer."
  :group 'weave)

(defface weave-annotation-summary-title
  '((t (:background "azure2")))
  "Face used to highlight the header of annotation editing buffer."
  :group 'weave)

(defface weave-marker
  '((t (:background "yellow")))
  "Face used to highlight the annotated region."
  :group 'weave)

(defface weave-strike-through-marker
  '((t (:strike-through "red")))
  "Face used to highlight the annotated region."
  :group 'weave)

(defcustom weave-annotation-file (format "~/.weave.es" (user-login-name))
  "file where your annotations are stored to"
  :type 'file
  :group 'weave)

(defcustom weave-annotation-external-files ()
  "files and directories where your readonly annotations are stored to"
  :type '(repeat (choice file directory))
  :group 'weave)

(defcustom weave-annotation-inline-show-header nil
  "Show date, name and mail-address in inline annotation"
  :set (lambda (symbol value)
	 (set-default symbol value)
	 (when (fboundp 'weave-reload-annotations)
	   (weave-reload-annotations t t)))
  :type  'boolean
  :group 'weave)

;;
;; Utils
;;
(defun weave-annotation-toggle-show-header ()
  (interactive)
  (setq weave-annotation-inline-show-header
	(not weave-annotation-inline-show-header))
  (weave-reload-annotations t t))

(defun weave-read-safely (stream)
  (condition-case nil
      (read stream)
    (error nil)))

;(weave-klist-value '(x 1 2 :a "a" :b "b") :b) => "b"
(defun weave-klist-value (klist keyword)
  (if klist
      (if (keywordp (car klist))
	  (if (eq keyword (car klist))
	      (cadr klist)
	    (weave-klist-value (cddr klist) keyword))
	(weave-klist-value (cdr klist) keyword))
	nil))

(defun weave-klist-append (klist keyword value)
  (reverse (cons value (cons keyword (reverse klist)))))

(defun weave-buffer-file-name (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (or (buffer-file-name)
	(and (eq major-mode 'dired-mode) dired-directory)
	(when (eq major-mode 'rfc-index-mode) (buffer-name)))))

(defun weave-make-completion-string-list (hash)
  (let ((table ()))
    (maphash
     (lambda (k v)
       (setq table (cons (symbol-name k) table)))
     hash)
    table))

(defun weave-gather-undefined-keywords ()
  (let ((gathered ()))
    (maphash (lambda (k v)
	       (mapc
		(lambda (e)
		  (mapc
		   (lambda (s)
		     (when (and (symbolp s)
				(not (member s gathered)))
		       (setq gathered (cons s gathered))))
		   (weave-klist-value e :keywords))
		  )
		v))
	     weave-annotations)
    gathered))

(defvar weave-read-keywords-history ())
(defun weave-read-keywords (prefix multi &optional recursion)
  (let ((s (completing-read (format "%sKeyword%s<%s>: "
				    (if prefix (concat prefix " ") "")
				    (if multi "s" "")
				    (if multi "multi" "single"))
			    (append
			     (weave-make-completion-string-list weave-keywords)
			     (mapcar 'symbol-name (weave-gather-undefined-keywords)))
			    nil nil
			    (unless recursion (car weave-read-keywords-history))
			    'weave-read-keywords-history)))
    (if (string= s "")
	nil
      (cons (intern s)
	    (if multi
		(weave-read-keywords prefix multi t)
	      ())))))

(defun weave-make-annotation-header (date full-name mailing-address)
  (if weave-annotation-inline-show-header
		  (concat
		   (propertize date 'face 'weave-annotation-date)
		   (propertize "  " 'face 'weave-annotation-base)
		   (propertize full-name 'face 'weave-annotation-name)
		   (propertize "  <" 'face 'weave-annotation-base)
		   (propertize mailing-address 'face 'weave-annotation-email)
		   (propertize ">" 'face 'weave-annotation-base)
		   (propertize "\n\n" 'face 'weave-annotation-base))
		""))

(defmacro weave-with-current-file (f &rest body)
  `(let* ((loaded (get-file-buffer ,f))
	  (result (with-current-buffer (find-file-noselect ,f)
		    (prog1 (progn ,@body)
		      (unless loaded
			(kill-buffer (current-buffer)))))))
     result))
(put 'weave-with-current-file 'lisp-indent-function 1)

(defun weave-get-user-full-name ()
  (or add-log-full-name (user-full-name)))

(defun weave-get-user-mailing-address ()
  (or add-log-mailing-address user-mail-address))

(defun weave-annotation-compare (e1 e2)
  (let ((et1 (date-to-time (weave-klist-value e1 :date)))
	(et2 (date-to-time (weave-klist-value e2 :date))))
    (cond
     ((> (car et1) (car et2)) nil)
     ((< (car et1) (car et2)) t)
     (t
      (cond
       ((> (cadr et1) (cadr et2)) nil)
       ((< (cadr et1) (cadr et2)) t)
       (t
	(equal (weave-klist-value e1 :full-name)
		    (weave-get-user-full-name))))))))

(defvar weave-annotations (make-hash-table :test 'equal))
(defvar weave-keywords    (make-hash-table :test 'eq))

;;
;; Target handler table
;;
(defvar weave-target-handlers (make-hash-table :test 'eq))
(defun weave-get-target-handler (type-or-target)
  (cond
   ((symbolp type-or-target)
    (let ((handler (gethash type-or-target
			    weave-target-handlers
			    ())))
      (or handler
	  (error (format "No such target type: %S" type-or-target)))))
   ((listp type-or-target)
    (weave-get-target-handler
     (weave-klist-value type-or-target :type)))
   (t
    (error (format "No way to get target type from: %S" type-or-target)))))
(defun weave-register-taregt-handlers (type klist)
  (puthash type klist weave-target-handlers))

(defun weave-target-new (type)
  (let ((handler (weave-get-target-handler type)))
    (funcall (weave-klist-value handler :make))))
(defun weave-target-load (es)
  (let ((handler (weave-get-target-handler
		  (weave-klist-value es :type))))
    (funcall (weave-klist-value handler :load)
	     es)))
(defun weave-target-type (target)
  (weave-klist-value target :type))
(defun weave-target-invoke-method (target k-method &rest args)
  (let ((handler (weave-get-target-handler target)))
    (let ((func (weave-klist-value handler k-method)))
      (if func
	  (apply func
		 target
		 args)
	(error (format "No such method: %S for target: %S" k-method target))))))
(defun weave-target-get-files (target)
  (weave-target-invoke-method target :get-files))
(defun weave-target-get-point (target file)
  (weave-target-invoke-method target :get-point file))
(defun weave-target-get-region (target file)
  (weave-target-invoke-method target :get-region file))
(defun weave-target-get-label (target file)
  (weave-target-invoke-method target :get-label file))
(defun weave-target-save-form (target)
  (weave-target-invoke-method target :save-form))
(defun weave-target-jump (target file)
  (weave-target-invoke-method target :jump file))

;;
;; Annotation handler table
;;

(defvar weave-annotation-handlers (make-hash-table :test 'eq))
(defun weave-get-annotation-handler (type-or-annotation)
  (cond
   ((symbolp type-or-annotation)
    (let ((handler (gethash type-or-annotation
			    weave-annotation-handlers
			    ())))
      (or handler
	  (error (format "No such annotation type: %S"
			 type-or-annotation)))))
   ((listp type-or-annotation)
    (weave-get-annotation-handler
     (weave-klist-value type-or-annotation :type)))
   (t
    (error (format "No way to get annotation type from: %S"
		   type-or-annotation)))))
(defun weave-register-annotation-handler (type klist)
  (puthash type klist weave-annotation-handlers))

(defun weave-annotation-new (type commit-func commit-args)
  (let ((handler (weave-get-annotation-handler type)))
    (funcall (weave-klist-value handler :make) commit-func commit-args)))
(defun weave-annotation-load (es)
  (let ((handler (weave-get-annotation-handler
		  (weave-klist-value es :type))))
    (funcall (weave-klist-value handler :load)
	     es)))
(defun weave-annotation-invoke-method (annotation k-method &rest args)
  (let ((handler (weave-get-annotation-handler annotation)))
    (let ((func (weave-klist-value handler k-method)))
      (if func
	  (apply func
		 annotation
		 args)
	(error
	 (format "No such method: %S for annotation: %S"
		 k-method annotation))))))

(defun weave-annotation-save-form (annotation)
  (weave-annotation-invoke-method annotation :save-form))

(defun weave-annotation-inline-format (annotation overlay
						    date full-name mailing-address)
  (weave-annotation-invoke-method annotation :inline-format
				    overlay
				    date full-name mailing-address))

(defun weave-annotation-list-format (annotation)
  (weave-annotation-invoke-method annotation :list-format))

;;
;; Frontend
;;
;; (defun weave-make-annotation-hash (annotation)
;;   (let ((h (make-hash-table :test 'eq))
;; 	(f (lambda (h a)
;; 	     (if (null a)
;; 		 h
;; 	       (puthash (car a) (cadr a) h)
;; 	       (funcall 'f (cddr a) h)))))
;;     (funcall 'f annotation h)))

(defun weave-draw-marker ()
  (interactive)
  (weave-annotate 'oneline t))

(defun weave-annotate-text ()
  (interactive)
  (weave-annotate 'text nil))

(defun weave-target-from-register (reg)
  (interactive "cRegister: ")
  (let ((target (let ((m (get-register reg)))
		  (when (markerp m)
		    (with-current-buffer (marker-buffer m)
		      (save-excursion
			(goto-char m)
			(weave-target-new
			 (if (eq major-mode 'dired-mode) 'directory 'file))))))))
    (when (interactive-p)
      (insert (format "%S" target)))
    target))

(defun weave-read-target-registers (seed regs)
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
      (weave-read-target-registers seed regs))
     (t
      (let ((target (weave-target-from-register r)))
	(if target
	    (weave-read-target-registers (cons target seed)
					   (cons r regs))
	  (message "`%c' doesn't contain a marker" r)
	  (sit-for 1)
	  (weave-read-target-registers seed regs)))))))

(defun weave-buffers-from-target-list (target-list seed)
  (if target-list
      (let ((target (car target-list)))
	;; TODO: use all files in the returned list.
	(weave-buffers-from-target-list (cdr target-list)
					  (cons
					   (find-file-noselect
					    (car (weave-target-get-files
						  target)))
					  seed)))
    seed))

(defun weave-points-from-target-list (target-list seed)
  (if target-list
      (let ((target (car target-list)))
	;; TODO: use all files in the returned list.
	(weave-points-from-target-list (cdr target-list)
					 (cons
					  (weave-target-get-point
					   target
					   (car (weave-target-get-files
						 target)))
					  seed)))
    seed))

(defun weave-regions-from-target-list (target-list seed)
  (if target-list
      (let ((target (car target-list)))
	;; TODO: use all files in the returned list.
	(weave-regions-from-target-list (cdr target-list)
					  (cons
					   (weave-target-get-region
					    target
					    (car (weave-target-get-files
						  target)))
					   seed)))
    seed))



(defun weave-annotate (type use-region)
  (interactive (list (intern (completing-read "Type: "
					      (weave-make-completion-string-list
					       weave-annotation-handlers)
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
	(full-name (weave-get-user-full-name))
	(mailing-address (weave-get-user-mailing-address)))
    (let ((target (weave-target-new target-type)))
      (let* ((point (weave-target-get-point target
					      (weave-buffer-file-name)))
	     (label (weave-target-get-label target
					      (weave-buffer-file-name)))
	     (commit-func (lambda (data args post-data commit-prefix)
			    (let ((target (weave-klist-value args :target))
				  (date   (weave-klist-value args :date))
				  (full-name (weave-klist-value args :full-name))
				  (mailing-address (weave-klist-value args :mailing-address))
				  (buffer (weave-klist-value args :buffer))
				  (point (weave-klist-value args :point)))
			      (let* ((target-list (cons target
							(if (not commit-prefix)
							    (list)
							  (weave-read-target-registers (list)
											 (list)))))
				     (buffers (weave-buffers-from-target-list target-list
										(list)))
				     (regions (weave-regions-from-target-list
					       target-list
					       (list))))
				(weave-commit-annotation data
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
	(weave-annotation-new annotation-type
				commit-func
				commit-args)))))

(defun weave-commit-annotation (annotation
				  target-list
				  date full-name mailing-address
				  buffers regions
				  keywords)
  (let ((home-r (weave-save-annotation
		 (mapcar 'weave-target-save-form target-list)
		 annotation date full-name mailing-address keywords)))
    (mapcar*
     (lambda (target b r)
       (weave-register-annotation target annotation
				    date full-name mailing-address keywords
				    home-r)
       ;;
       (weave-insert-annotation   b r
				    annotation date full-name mailing-address keywords))
     target-list buffers regions)))

(defun weave-register-annotation (target annotation date full-name mailing-address keywords
					   annotation-home)
  (mapc
   (lambda (file)
     (let ((entry (gethash file weave-annotations ())))
       (puthash file (cons (list :target target
				 :annotation annotation
				 :date date
				 :full-name full-name
				 :mailing-address mailing-address
				 :keywords keywords
				 :annotation-home annotation-home) entry)
	       weave-annotations)))
     (weave-target-get-files target)))

(defun weave-save-annotation (target-list annotation date full-name mailing-address keywords)
  (weave-with-current-file weave-annotation-file
    (goto-char (point-max))
    (let ((start (point)))
      (insert (format "%S\n" (list 'weave-annotation
				   :version 0
				   :target-list target-list
				   :annotation-list (list (weave-annotation-save-form annotation))
				   :date date
				   :full-name full-name
				   :mailing-address mailing-address
				   :keywords keywords)))
      (save-buffer)
    (list weave-annotation-file
	  start
	  (point)))))

(defface weave-auto-annotation
  '((((background light)) 
     (:foreground "gray70" :italic t :underline nil))
    (((background dark)) 
     (:foreground "gray30" :italic t :underline nil)))
  ""
  :group 'weave)

(defun weave-stitch-by-line-and-col (buffer line col si-proc keywords)
  (weave-stitch buffer (with-current-buffer buffer 
			   (goto-line line)
			   ;;(line-move-to-column col)
			   (forward-char col)
			   (point))
		  si-proc keywords))

(defun weave-stitch (buffer pos si-proc keywords)
  (with-current-buffer buffer
    (when (<= pos (point-max))
      (let* ((o (make-overlay pos pos buffer))
	     (si (funcall si-proc o)))
	(overlay-put o 'after-string si)
	;;      (overlay-put o 'display `((margin left-margin) "XXX"))
	(overlay-put o 'weave-annotation t)
	(overlay-put o 'weave-keywords keywords)))))

(defun weave-insert-point-annotation (buffer pos annotation date full-name mailing-address keywords)
  (with-current-buffer buffer
    (when (<= pos (point-max))
      (let* ((o (make-overlay pos pos buffer))
	     (si (weave-annotation-inline-format annotation
						   o
						   date
						   full-name
						   mailing-address)))
	;; FILTER the SI length here.
	(overlay-put o 'after-string si)
	;;      (overlay-put o 'display `((margin left-margin) "XXX"))
	(overlay-put o 'weave-annotation t)
	(overlay-put o 'weave-keywords keywords)))))

;;
;;(require 'skk)
(require 'avoid)
(defun weave-tooltip-show-at-point (text)
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

(defun weave-show-annotation ()
  (interactive)
  (unless (boundp 'weave-in-show-annotation-dirty-hack-marker)
    (let ((weave-in-show-annotation-dirty-hack-marker t))
      (let ((overlays (overlays-at (point)))
	    found)
	(while overlays
	  (let ((o (car overlays)))
	    (when (overlay-get o 'weave-annotation)
	      (weave-tooltip-show-at-point 
	       (replace-regexp-in-string "\n$" "" (overlay-get o 'help-echo-string)
					 ))
	      (setq overlays nil))))))))

(defun weave-insert-region-annotation (buffer start end face annotation date full-name mailing-address keywords)
  (with-current-buffer buffer
    (when (<= end (point-max))
      (let* ((o (make-overlay start end buffer))
	     (si (weave-annotation-inline-format annotation
						   o
						   date
						   full-name
						   mailing-address)))
	;; FILTER the SI length here.
	(overlay-put o 'help-echo-string si)
	;(overlay-put o 'mouse-face 'highlight)
	(overlay-put o 'face (or (and face
				      (facep face)
				      face)
				 'weave-marker))
	;(overlay-put o 'point-entered (lambda (o n) 
	;				(weave-show-annotation)))
	(let ((buffer-read-only nil))
	  (put-text-property start end 'point-entered
			     (lambda (o n)
			       (weave-show-annotation)))
	  (not-modified)
	  )
	(let ((map (make-sparse-keymap "Weave Marker")))
	  (define-key map [return] 'weave-show-annotation)
	  (overlay-put o 'keymap map)
	  )
	;;      (overlay-put o 'display `((margin left-margin) "XXX"))
	(overlay-put o 'weave-annotation t)
	(overlay-put o 'weave-keywords keywords)))))


(defun weave-insert-annotation (buffer region annotation date full-name mailing-address keywords)
  (if (eq (car region) (cadr region))
      (weave-insert-point-annotation buffer 
				       (car region)
				       annotation date full-name mailing-address keywords)
    (weave-insert-region-annotation buffer
				      (car region)
				      (cadr region)
				      (caddr region)
				      annotation date full-name mailing-address keywords)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun weave-insert-annotations (&optional buffer)
  ;; Checking (boundp 'dirname) here is quite dirty hack.
  ;; See `dired-readin'. `dired-after-readin-hook' called twice for
  ;; each `revert-buffer'.
  (when (or (not (eq major-mode 'dired-mode))
	    (not (boundp 'dirname))
	    (boundp 'failed))
    (with-current-buffer (or buffer (current-buffer))
      (let ((file (weave-buffer-file-name (current-buffer))))
	(when file
	  (let ((entry (gethash file weave-annotations nil)))
	    (mapcar
	     (lambda (e)
	       (weave-insert-annotation
		;; (weave-klist-value e :target)
		(current-buffer)
		(weave-target-get-region (weave-klist-value
					    e
					    :target)
					   file)
		(weave-klist-value e :annotation)
		(weave-klist-value e :date)
		(weave-klist-value e :full-name)
		(weave-klist-value e :mailing-address)
		(weave-klist-value e :keywords)))
	     (nreverse (sort entry 'weave-annotation-compare)))))))))


(defun weave-delete-annotations (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (mapc
     (lambda (o)
       (when (overlay-get o 'weave-annotation)
	 (delete-overlay o)))
     (overlays-in (point-min)
		  (1+ (point-max))
		  ))))

(defun weave-reload-annotations (&optional all-buffer just-rerender)
  (interactive "P")
  (mapcar
   'weave-delete-annotations
   (if all-buffer (buffer-list) (list (current-buffer))))
  (unless just-rerender
    (setq weave-annotations (make-hash-table :test 'equal))
    (setq weave-keywords (make-hash-table :test 'eq))
    (weave-load-annotations))
  (mapcar
   'weave-insert-annotations
   (if all-buffer (buffer-list) (list (current-buffer)))))

(defun weave-load-annotation (stream file-name)
  ;; TODO start, end, and file-name are not used yet.
  (let ((start (point))
	(r (weave-read-safely stream))
	(end   (point)))
    (cond
     ((eq (car r) 'weave-annotation)
      (let ((target-list (mapcar
			  'weave-target-load
			  (weave-klist-value r :target-list)))
	    (annotation-list (mapcar
			      'weave-annotation-load
			      (weave-klist-value r :annotation-list)))
	    (date (weave-klist-value r :date))
	    (full-name (weave-klist-value r :full-name))
	    (mailing-list (weave-klist-value r :mailing-address))
	    (keywords (weave-klist-value r :keywords)))
	(mapc
	 (lambda (target)
	   (mapc
	      (lambda (annotation)
		  (weave-register-annotation target
					       annotation
					       date full-name
					       mailing-list
					       keywords
					       (list file-name start end)))
	      annotation-list))
	 target-list)
	))
     ((eq (car r) 'define-keyword)
      (weave-register-keyword (cadr r)
				(weave-klist-value r :subject)
				(weave-klist-value r :date)
				(weave-klist-value r :full-name)
				(weave-klist-value r :mailing-address)
				(weave-klist-value r :keywords))))
    r))

(defun weave-build-file-list (file-and-dir-list seed)
  (if (null file-and-dir-list)
      seed
    (weave-build-file-list
     (cdr file-and-dir-list)
     (let ((file-or-dir (car file-and-dir-list)))
       (if (file-directory-p file-or-dir)
	   (weave-build-file-list
	    (directory-files file-or-dir t ".*\\.es$")
	    seed)
	 (if (member file-or-dir seed)
	     seed
	   (cons file-or-dir seed)))))))

(defun weave-load-annotations ()
  (mapc
   (lambda (f)
     (weave-with-current-file f
       (goto-char (point-min))
       (while (weave-load-annotation (current-buffer)
				       f)
	 t)
       ))
   (let ((file (expand-file-name weave-annotation-file))
	 (file-list (weave-build-file-list (mapcar
					      'expand-file-name
					      weave-annotation-external-files)
					     (list))))
     (if (member file file-list)
	 ;;
	 ;; It seems that there are hash tabel bugs in GNU Emacs.
	 ;; So I shuffle what I'll do.
	 ;;
	 (reverse file-list)
       (cons file file-list)))))

(defun weave-register-keyword (keyword subject date full-name mailing-address parent-keywords)
  (let ((entry (gethash keyword weave-keywords ())))
    (puthash keyword (cons (list :subject subject
				 :date date
				 :full-name full-name
				 :mailing-address mailing-address
				 :keywords parent-keywords) entry)
	     weave-keywords)))

(defun weave-lookup-keyword (keyword)
  (reverse (gethash keyword weave-keywords nil)))

(defvar weave-toggle-annotation 1)
(defun weave-toggle-annotation (arg)
  (interactive "P")
  (cond ((and (numberp arg) (< arg 0))
	 (setq weave-toggle-annotation -1)
	 (mapcar
	  'weave-delete-annotations
	  (buffer-list)))
	((and (numberp arg) (> arg 0))
	 (setq weave-toggle-annotation 1)
	 (weave-reload-annotations t t)
	 )
	(t
	 (weave-toggle-annotation
	  (if (> weave-toggle-annotation 0) -1 1)))))

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
(defun current-line ()
  "Current line number of cursor."
  (+ (count-lines (point-min) (point))
     (if (= (current-column) 0) 1 0)))
;; =====================================================================
(defun weave-safe-which-function ()
  (condition-case nil
      (which-function)
    (error nil)))

(defun weave-file-target-new ()
  (let* ((func    (weave-safe-which-function))
	 (line    (save-restriction (widen) (current-line)))
	 (target `(target :type file
			  :file ,(weave-buffer-file-name)
			  :point ,(point)
			  :coding-system ,buffer-file-coding-system
			  :line ,line)))
    (if func
	(weave-klist-append target :which-func func)
      target)))
(defun weave-file-target-get-files (target)
  (list (weave-klist-value target :file)))
(defun weave-file-target-get-point (target file)
  (weave-klist-value target :point))
(defun weave-file-target-get-region (target file)
  (let ((p (weave-file-target-get-point target file)))
    (list p p)))
(defun weave-file-target-get-label (target file)
  (let ((f (weave-klist-value target :which-func)))
    (if f
	(format "Function: %s" f)
      (format "Point: %s" (weave-klist-value target :point)))))
(defun weave-file-target-save-form (target)
  target)
(defun weave-file-target-load (es)
  es)
(defun weave-file-target-jump (target file)
  (when file
    (find-file file)
    (goto-char (weave-file-target-get-point target file))))

(weave-register-taregt-handlers
 'file
 '(:make      weave-file-target-new
   :load      weave-file-target-load
   :get-files weave-file-target-get-files
   :get-point weave-file-target-get-point
   :get-region weave-file-target-get-region
   :get-label weave-file-target-get-label
   :save-form weave-file-target-save-form
   :jump      weave-file-target-jump))

;;
;; Region Target Backend 
;;
(defun weave-region-target-new ()
  (let ((b (region-beginning))
	(e (region-end)))
    (when (eq b e)
      (error "the region size is 0"))
    (let* ((func (weave-safe-which-function))
	   (line (save-restriction (widen) (current-line)))
	   (target `(target :type region
			    :subtype file
			    :file ,(weave-buffer-file-name)
			    :region (,b ,e)
			    :coding-system ,buffer-file-coding-system
			    :line ,line
			    :face ,(read-face-name "Face" 'weave-marker))))
      (if func
	  (weave-klist-append target :which-func func)
	target))))
(defun weave-region-target-get-files (target)
  (list (weave-klist-value target :file)))
(defun weave-region-target-get-point (target file)
  (car (weave-klist-value target :region)))
(defun weave-region-target-get-region (target file)
  (reverse
   (cons (weave-klist-value target :face)
	 (reverse (weave-klist-value target :region)))))
;; TODO
(defun weave-region-target-get-label (target file)
  (apply 'format "Function: %s\nRegion: %s - %s" 
	 (weave-klist-value target :which-func)
	 (weave-klist-value target :region)))
(defun weave-region-target-save-form (target)
  target)
(defun weave-region-target-load (es)
  es)
(defun weave-region-target-jump (target file)
  (when file
    (find-file file)
    (goto-char (weave-region-target-get-point target file))))

(weave-register-taregt-handlers
 'region
 '(:make      weave-region-target-new
   :load      weave-region-target-load
   :get-files weave-region-target-get-files
   :get-point weave-region-target-get-point
   :get-region weave-region-target-get-region
   :get-label weave-region-target-get-label
   :save-form weave-region-target-save-form
   :jump      weave-region-target-jump))				  

;;
;; Directory Target Backend
;;
(defun weave-directory-target-new ()
  `(target :type directory
	   :directory ,(expand-file-name (weave-buffer-file-name))
	   :item ,(dired-get-filename t t))
  ;; ??? coding system
  )
(defun weave-directory-target-get-files (target)
  (list (weave-klist-value target :directory)))
;; (defun weave-directory-target-get-point (target directory)

;;   (let ((item (weave-klist-value target :item)))
;;     (if (and (equal (weave-buffer-file-name) directory)
;; 	     (eq major-mode 'dired-mode))
;; 	(let ((absolute-item (concat (file-name-as-directory directory) item)))
;; 	  (condition-case nil
;; 	      (save-excursion
;; 		(dired-goto-file absolute-item)
;; 		(beginning-of-line)
;; 		(point))
;; 	      (error 0)))
;;       0)))

(defun weave-directory-target-get-point (target directory)

  (let* ((item (weave-klist-value target :item))
	 (dirbuf (dired-buffers-for-dir directory))
	 (absolute-item (concat (file-name-as-directory directory) item)))
    (if (car dirbuf)
	(with-current-buffer (car dirbuf)
	  (condition-case nil
	      (save-excursion
		(dired-goto-file absolute-item)
		(beginning-of-line)
		(point))
	    (error 0)))
      0)))

(defun weave-directory-target-get-region (target directory)
  (let ((p (weave-directory-target-get-point target directory)))
    (list p p)))

(defun weave-directory-target-get-label (target directory)
  (format "Item: %s" (weave-klist-value target :item)))

(defun weave-directory-target-save-form (target)
  `(target :type  ,(weave-klist-value target :type)
	   :directory  ,(weave-klist-value target :directory)
	   :item ,(weave-klist-value target :item)))
(defun weave-directory-target-load (es)
  es)

(defun weave-directory-target-jump (target file)
  (when (and file
	     (file-directory-p file))
    (dired file)
    (goto-char (weave-directory-target-get-point target file))))

(weave-register-taregt-handlers
 'directory
 '(:make      weave-directory-target-new
   :load      weave-directory-target-load
   :get-files weave-directory-target-get-files
   :get-point weave-directory-target-get-point
   :get-region weave-directory-target-get-region
   :get-label weave-directory-target-get-label
   :save-form weave-directory-target-save-form
   :jump      weave-directory-target-jump))


(defun weave-generic-annotation-load (es)
  es)
(defun weave-generic-annotation-save-form (annotation)
  `(annotation :type ,(weave-klist-value annotation :type)
	       :data  ,(weave-klist-value annotation :data)))

;;
;; Annotation Backend
;;
(defun weave-oneline-annotation-new (commit-func commit-args)
  (funcall commit-func
	   `(anntation :type oneline
		       :data ,(read-from-minibuffer "Annotation: "))
	   commit-args
	   (weave-read-keywords "Commit with" t)
	   current-prefix-arg))

(defun weave-oneline-annotation-inline-format (annotation
						 overlay
						 date full-name mailing-address)
  (let ((pos (overlay-start overlay)))
    (let* ((b (char-before pos)))
      (concat ;; TODO
	      (weave-make-annotation-header date full-name mailing-address)
	      ;;
	      (propertize
	       (weave-klist-value annotation :data)
	       'face 'weave-annotation-body)
	      (propertize
	       "\n"
	       'face 'weave-annotation-base)))))

(defun weave-oneline-annotation-list-format (annotation)
  (weave-klist-value annotation :data))

(weave-register-annotation-handler
 'oneline
 '(:make          weave-oneline-annotation-new
   :load          weave-generic-annotation-load
   :save-form     weave-generic-annotation-save-form
   :inline-format weave-oneline-annotation-inline-format
   :list-format   weave-oneline-annotation-list-format
   ))

(defvar weave-edit-annotation-commit-func nil)
(defvar weave-edit-annotation-commit-args nil)
(defvar weave-edit-annotation-window-configuration nil)
(defvar weave-edit-annotation-make-data nil)
(defvar weave-edit-annotation-make-post-data nil)
(defun weave-edit-annotation-new-0 (bname header commit-func commit-args mode
					    make-data make-post-data)
  (let ((wc (current-window-configuration))
	(b  (get-buffer-create bname)))
    (with-current-buffer b
      (funcall mode)
      (set (make-variable-buffer-local
	    'weave-edit-annotation-commit-func) commit-func)
      (set (make-variable-buffer-local
	    'weave-edit-annotation-commit-args) commit-args)
      (set (make-variable-buffer-local
	    'weave-edit-annotation-window-configuration) wc)
      (set (make-variable-buffer-local
	    'weave-edit-annotation-make-data) make-data)
      (set (make-variable-buffer-local
	    'weave-edit-annotation-make-post-data) make-post-data)
      (let ((o (make-overlay (point-min) (point-min))))
	;; TODO Remove older overlays
	(overlay-put o 'weave-edit-annotation-header t)
	(overlay-put o 'before-string header)
	(local-set-key "\C-c\C-c"
		       (lambda (prefix) (interactive "P")
			 (funcall
			  weave-edit-annotation-commit-func
			  (funcall weave-edit-annotation-make-data
				   (buffer-substring-no-properties
				    (point-min)
				    (point-max)))
			  weave-edit-annotation-commit-args
			  (funcall weave-edit-annotation-make-post-data
				   weave-edit-annotation-commit-args)
			  prefix)
			 (let ((abuffer (current-buffer))
			       (obuffer (weave-klist-value
					 weave-edit-annotation-commit-args
					 :buffer))
			       (opoint  (weave-klist-value
					 weave-edit-annotation-commit-args
					 :point)))
			   (set-window-configuration
			    weave-edit-annotation-window-configuration)
			   (when (buffer-live-p (get-buffer obuffer))
			     (set-buffer obuffer)
			     (goto-char opoint))
			   (kill-buffer abuffer))
			 ))
	(local-set-key "\C-c\C-l" (lambda () (interactive)
				    (set-window-point
				     (display-buffer
				      (weave-klist-value weave-edit-annotation-commit-args :buffer))
				     (weave-klist-value weave-edit-annotation-commit-args :point))
				    ))
	))
    (pop-to-buffer b)))

(defun weave-edit-annotation-new (commit-func commit-args mode etype)
  (weave-edit-annotation-new-0 (format "*Annotation<%s:%d>*"
					 (buffer-name (weave-klist-value commit-args :buffer))
					 (weave-klist-value commit-args :point))
				 (concat
				  (propertize
				   (format "File: %s\nPoint: %d\nKeywords: \n"
					   (buffer-name (weave-klist-value commit-args :buffer))
					   (weave-klist-value commit-args :point))
				   'face 'weave-annotation-edit-header
				   'mouse-face 'highlight)
				  "----\n")
				 commit-func commit-args mode
				 `(lambda (bstring)
				    (list 'annotation :type ',etype
						      :data bstring))
				 (lambda (commit-args) 
				   (weave-read-keywords nil t))))

(defun weave-text-annotation-new (commit-func commit-args)
  (weave-edit-annotation-new commit-func commit-args 'text-mode 'text))

(defun weave-text-annotation-inline-format (annotation
						 overlay
						 date full-name mailing-address)
  (let ((pos (overlay-start overlay)))
    (let* ((b (char-before pos))
	   (bn (or (eq b ?\n) (not b)))
	   (an (eq (char-after pos) ?\n)))
      (concat (propertize
	       (concat (if (eq major-mode 'dired-mode) "" "\n")
		       (if bn "" "\n" ))
	       'face 'weave-annotation-base)
	      (weave-make-annotation-header date full-name mailing-address)
	      (propertize
	       (weave-klist-value annotation :data)
	       'face 'weave-annotation-body)
	      (propertize
	       (concat
		(if (eq major-mode 'dired-mode) "" "\n")
		(if an "" "\n" ))
	       'face 'weave-annotation-base)))))

(defun weave-text-annotation-list-format (annotation)
  (weave-klist-value annotation :data))

(weave-register-annotation-handler
 'text
 '(:make          weave-text-annotation-new
		  ;; TODO
   :load          weave-generic-annotation-load
   :save-form     weave-generic-annotation-save-form
   :inline-format weave-text-annotation-inline-format
   :list-format   weave-text-annotation-list-format))

;;
;; Graphviz Common
;;
(defun weave-graphviz-annotation-inline-format (cmd
						  annotation
						  overlay
						  date full-name mailing-address)
  (let ((pos (overlay-start overlay)))
    (let* ((b (char-before pos))
	   (bn (or (eq b ?\n) (not b)))
	   (an (eq (char-after pos) ?\n)))
      (concat (propertize (concat "\n" (if bn "" "\n" )) 'face 'weave-annotation-base)
	      (weave-make-annotation-header date full-name mailing-address)
	      (propertize
	       " "
	       'display (weave-graphviz-create-image (weave-klist-value annotation :data)
						       cmd))
	      ;;
	      (propertize
	       (concat
		"\n"
		(if an "" "\n" ))
	       'face 'weave-annotation-base)))))

(defun weave-graphviz-annotation-list-format (annotation cmd)
  (concat "\n"
	  (propertize
	   " "
	   'display (weave-graphviz-create-image (weave-klist-value annotation :data)
						   cmd))
	  "\n"))

(defun weave-graphviz-make-command-line (cmd dotfile pngfile)
  (if (stringp cmd)
      (format "%s -T png %s > %s" cmd dotfile pngfile)
    (funcall cmd dotfile pngfile)))
(defun weave-graphviz-create-image (code cmd)
  (save-excursion
    (let* ((dotfile (make-temp-file "s-a" nil ".dot"))
	   (pngfile  (make-temp-file "s-a" nil ".png")))
      (with-temp-buffer
	(insert code)
	(write-file dotfile)
	)
    (let ((status (shell-command
		   (weave-graphviz-make-command-line cmd dotfile pngfile))))
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
     (defun ,(intern (format "weave-%S-annotation-new" cmd)) (commit-func commit-args)
       (weave-edit-annotation-new commit-func commit-args
				    (quote graphviz-dot-mode)
				    (quote ,(intern (format "graphviz-%S" cmd)))))
     ;;
     (defun ,(intern (format "weave-%S-annotation-inline-format" cmd)) (annotation
									  overlay
									  date full-name mailing-address)
       (weave-graphviz-annotation-inline-format ,(symbol-name cmd)
						  annotation
						  overlay
						  date full-name mailing-address))
     (defun ,(intern (format "weave-%S-annotation-list-format" cmd)) (annotation)
       (weave-graphviz-annotation-list-format annotation ,(symbol-name cmd)))
     (weave-register-annotation-handler
      (quote ,(intern (format "graphviz-%S" cmd)))
      (quote (:make          ,(intern (format "weave-%S-annotation-new" cmd))
	      :load          weave-generic-annotation-load
	      :save-form     weave-generic-annotation-save-form
	      :inline-format ,(intern (format "weave-%S-annotation-inline-format" cmd))
	      ;; TODO
	      :list-format   ,(intern (format "weave-%S-annotation-list-format" cmd))
	      )))))
(define-graphviz dot)
(define-graphviz neato)
(define-graphviz twopi)
(define-graphviz circo)
(define-graphviz fdp)


;;
;; Mscgen
;;
(defun weave-mscgen-make-command-line (dotfile pngfile)
  (format "mscgen -T png -i %s -o %s" dotfile pngfile))
(defun weave-mscgen-annotation-new (commit-func commit-args)
  (weave-edit-annotation-new commit-func commit-args 'graphviz-dot-mode 'mscgen))
(defun weave-mscgen-annotation-inline-format (annotation
						overlay
						date full-name mailing-address)
  (weave-graphviz-annotation-inline-format
   'weave-mscgen-make-command-line
   annotation
   overlay
   date full-name mailing-address))

(defun weave-mscgen-annotation-list-format (annotation)
  (weave-graphviz-annotation-list-format annotation
					   'weave-mscgen-make-command-line))

(weave-register-annotation-handler
 'mscgen
 '(:make          weave-mscgen-annotation-new
   :load          weave-generic-annotation-load
   :save-form     weave-generic-annotation-save-form
   :inline-format weave-mscgen-annotation-inline-format
   :list-format   weave-mscgen-annotation-list-format))

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
(defun weave-groff-annotation-new (commit-func commit-args)
  (weave-edit-annotation-new commit-func commit-args 'nroff-mode 'groff))

(defun weave-groff-make-gs-command (res)
  (format
   "gs -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=png256 -r%dx%d -sOutputFile=- -q -"
   res
   res))

(defun weave-groff-make-command-line (dotfile pngfile)
  (format
   "cat %s | groff -t -T ps - | %s | convert -trim - %s"
   dotfile
   (weave-groff-make-gs-command 150)
   pngfile))

(defun weave-groff-annotation-inline-format (annotation
					     overlay
					     date full-name mailing-address)
  (weave-graphviz-annotation-inline-format
   'weave-groff-make-command-line
   annotation
   overlay
   date full-name mailing-address))

(defun weave-groff-annotation-list-format (annotation)
  (weave-graphviz-annotation-list-format
   annotation
   'weave-groff-make-command-line))

(weave-register-annotation-handler
 'groff
 '(:make          weave-groff-annotation-new
		  ;; TODO
   :load          weave-generic-annotation-load
   :save-form     weave-generic-annotation-save-form
   :inline-format weave-groff-annotation-inline-format
   :list-format   weave-groff-annotation-list-format))

;;
;; Listing and reporting
;;
(defun weave-list-annotation-about-current-file ()
  (interactive)
  (let ((target-file (weave-buffer-file-name)))
    (weave-list-annotation-with-filter
     (format "*List Annotations: %s*" (buffer-name))
     (lambda (k e) (string= k target-file))
     t
     t)))

(defun weave-list-annotation-about-keyword (keywords buffer-or-name need-erasing)
  (let ((and-set nil))
    (fset 'and-set (lambda (s1 s2)
		     (if (car s1)
			 (and (member (car s1) s2)
			      (and-set (cdr s1) s2))
		       t)))
    (weave-list-annotation-with-filter buffer-or-name
					 (lambda (k e)
					   (if keywords
					       (and-set
						keywords
						(weave-klist-value e :keywords))
					     t))
					 need-erasing
					 nil)))

(defun weave-list-annotation (all-filter)
  (interactive "P")
  (let* ((keywords (unless all-filter
		       (weave-read-keywords "List annotations for" t)
		       ))
	 (bname (if keywords
		    (format "*List Annotations/%S*" keywords)
		  "*List ALL Annotations*"
		  )))
    (weave-list-annotation-about-keyword keywords
					   bname
					   t)))

(defvar weave-list-annotation-window-config nil)
(defun weave-list-annotation-with-filter (buffer-or-name filter need-erasing show-keyword)
  (let ((b (if (bufferp buffer-or-name)
	       buffer-or-name
	     (get-buffer-create buffer-or-name))))
    (with-current-buffer b
      (setq buffer-read-only t)
      (set (make-variable-buffer-local
	    'weave-list-annotation-window-config) (current-window-configuration))
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
		 weave-annotations)
	(mapcar
	 (lambda (l)
	   (let ((k (nth 0 l))
		 (e (nth 1 l)))
	     (insert
	      "\n"
	      (concat (weave-make-annotation-header
		       (weave-klist-value e :date)
		       (weave-klist-value e :full-name)
		       (weave-klist-value e :mailing-address))
		      (let ((file (file-name-nondirectory k)))
			(propertize (concat
				     (if (equal "" file)
					 ""
				       (concat "File: " (file-name-nondirectory k) "\n"))
				     "Directory: " (file-name-directory k) "\n"
				     (weave-target-get-label
				      (weave-klist-value e :target)
				      k) "\n"
				      (format "Home: %S\n" (weave-klist-value e :annotation-home))
				      (if show-keyword
					  (format "Keywords: %S\n"
						  (weave-klist-value e :keywords))
					""))
				    'face 'weave-annotation-base
				    'mouse-face 'highlight
				    'weave-file   k
				    'weave-target (weave-klist-value e :target)
				    'weave-home   (weave-klist-value e :annotation-home)))
		      ))
	     ;;
	     (insert (propertize (weave-annotation-list-format
				  (weave-klist-value e :annotation))
				 'weave-file   k
				 'weave-target (weave-klist-value e :target)
				 'weave-home   (weave-klist-value e :annotation-home)))
	     (insert "\n")
	     (insert "\n")
	     ))
	 (sort filter-annotations (lambda (a1 a2)
				    (weave-annotation-compare (nth 1 a1)
								(nth 1 a2)))))

	(local-set-key [return]  'weave-list-jump-to-target)
	(local-set-key [(shift return)]  'weave-list-jump-to-home)
	(local-set-key [mouse-2] 'weave-list-jump-to-target-with-mouse)
	(goto-char (point-min))))
    (pop-to-buffer b)))

(defun weave-list-jump-to-target-with-mouse (event)
  (interactive "e")
  (save-excursion
    (set-buffer (window-buffer (posn-window (event-end event))))
    (save-excursion
      (goto-char (posn-point (event-end event)))
      (weave-list-jump-to-target))))

(defun weave-list-jump-to-target ()
  (interactive)
  (let ((file   (get-text-property (point) 'weave-file))
	(target (get-text-property (point) 'weave-target)))
    (when weave-list-annotation-window-config
      (set-window-configuration weave-list-annotation-window-config))
    (weave-target-jump target file)
    ))

(defun weave-home-jump (home)
  (when (find-file (car home))
    (goto-char (cadr home))
    (search-forward "(" nil nil)))

(defun weave-list-jump-to-home ()
  (interactive)
  (let ((home (get-text-property (point) 'weave-home)))
    (when weave-list-annotation-window-config
      (set-window-configuration weave-list-annotation-window-config))
    (weave-home-jump home)))

(defun weave-list-files-annotate-with-keyword (keyword)
  (interactive (list (weave-read-keywords "List Annotations in This File for" nil)))
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
	      (when (member key (weave-klist-value e :keywords))
		(let ((a (assoc k files)))
		  (if a
		      (setcdr a (1+ (cdr a)))
		    (setq files (cons (cons k 1) files))))))
	    v))
	 weave-annotations)
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
	 (sort files
	       (lambda (a b)
		 (> (cdr a) (cdr b)))))
	(goto-char (point-min))
	(require 'ffap)
	(local-set-key [return] 'ffap)
	))
    (pop-to-buffer b)))

(defun weave-save-keyword (keyword subject date full-name mailing-address parent-keywords)
  (weave-with-current-file weave-annotation-file
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


(defun weave-commit-keyword (keyword subject parent-keywords)
  (let ((date (current-time-string))
	(full-name (weave-get-user-full-name))
	(mailing-address (weave-get-user-mailing-address)))
    (weave-save-keyword     keyword
			      subject
			      date
			      full-name
			      mailing-address
			      parent-keywords)
    (weave-register-keyword keyword
			      subject
			      date
			      full-name
			      mailing-address
			      parent-keywords)))

(defun weave-edit-meta-new (commit-func commit-args mode etype)
  (weave-edit-annotation-new-0 (format "*Meta Annotation: %S*"
					 (weave-klist-value commit-args :keyword))
				 (concat
				  (propertize
				   (format "Keyword: %S\n" (weave-klist-value
							    commit-args
							    :keyword))
				   'face 'weave-annotation-edit-header)
				  "----\n")
				 commit-func
				 commit-args mode
				 (lambda (bstring) bstring)
				 (lambda (commit-args) (weave-klist-value
							    commit-args
							    :keyword))))

(defun weave-annotate-meta (keyword)
  (interactive (weave-read-keywords "Meta Annotation" nil))
  (weave-edit-meta-new (lambda (data args post-data prefix)
				   (weave-commit-keyword
				    (weave-klist-value args :keyword)
				    data
				    post-data))
			 `(:keyword ,keyword
			   :point ,(point)
			   :buffer ,(current-buffer))
			 'text-mode nil))

(defun weave-report-about-keyword (keywords)
  (interactive (list (weave-read-keywords "Make Report for" nil)))
  (let* ((key (car keywords))
	 (b (get-buffer-create (format "*Report: %S*" key)))
	 (kentries (weave-lookup-keyword key)))
    (with-current-buffer b
      (let ((buffer-read-only nil))
	(erase-buffer)
	(mapc
	 (lambda (e)
	   (insert "\n")
	   (let ((weave-annotation-inline-show-header t))
	     (insert (weave-make-annotation-header
		      (weave-klist-value e :date)
		      (weave-klist-value e :full-name)
		      (weave-klist-value e :mailing-address)
		      )))
	   (let ((p (point)))
	     (insert "\n")
	     (insert (weave-klist-value e :subject))
	     (insert "\n")
	     (insert "\n")
	     (put-text-property p (point) 'face 'weave-annotation-summary-title)
	     (put-text-property p (point) 'mouse-face 'highlight)
	     ))
	 kentries)))
    (when key
      (weave-list-annotation-about-keyword (list key)
					     b
					     nil))))

(defun weave-find-annotation-file ()
  (interactive)
  (find-file weave-annotation-file)
  (goto-char (point-max)))

(weave-reload-annotations t)

(add-hook (if (boundp 'find-file-hook) 'find-file-hook 'find-file-hooks)
	  'weave-insert-annotations)
(add-hook 'rfc-article-mode-hook
	  'weave-insert-annotations)
(add-hook 'rfc-index-mode-hook
	  'weave-insert-annotations)

(add-hook 'dired-before-readin-hook 'weave-delete-annotations)
(add-hook 'dired-after-readin-hook 'weave-insert-annotations)
(add-hook 'before-revert-hook 'weave-delete-annotations)
;;
(define-key ctl-x-4-map  "A"   'weave-annotate-text)

(define-key ctl-x-map    "AA"  'weave-annotate)
(define-key ctl-x-map    "A "  'weave-draw-marker)

(define-key ctl-x-map    "AL"  'weave-list-annotation)
(define-key ctl-x-map    "AB"  'weave-list-files-annotate-with-keyword)
(define-key ctl-x-map    "AF"  'weave-find-annotation-file)
(define-key ctl-x-map    "AK"  'weave-report-about-keyword)
(define-key ctl-x-map    "AO"  'weave-annotate-meta)
(define-key ctl-x-map    "AT"  'weave-annotation-toggle-show-header)
;;
(define-key ctl-x-map    "An"  'weave-next-annotation)
(define-key ctl-x-map    "Ap"  'weave-previous-annotation)
(define-key ctl-x-map    "Al"  'weave-list-annotation-about-current-file)
(define-key ctl-x-map    "Ag"  'weave-reload-annotations)
(define-key ctl-x-map    "At"  'weave-toggle-annotation)




;;
;; Navigation
;;
(defun weave-next-annotation ()
  (interactive)
  (goto-char (next-overlay-change (point)))
  (while (and (not (eobp))
	      (not (member t (mapcar
			      (lambda (o)
				(overlay-get o 'weave-annotation))
			      (overlays-in (point) (1+ (point)))))))
    (goto-char (next-overlay-change (point)))))

(defun weave-previous-annotation ()
  (interactive)
  (goto-char (previous-overlay-change (point)))
  (while (and (not (bobp))
	      (not (member t (mapcar
			      (lambda (o)
				(overlay-get o 'weave-annotation))
			      (overlays-in (point) (1+ (point)))))))
    (goto-char (previous-overlay-change (point)))))

(defvar weave-annotation-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c4A"    'weave-annotate-text)
    (define-key map "\C-ca"     'weave-annotate)
    (define-key map "\C-cA"     'weave-annotate-text)
    (define-key map "\C-cl"     'weave-list-annotation-about-current-file)
    (define-key map "\C-cL"     'weave-list-annotation)
    (define-key map "\C-ck"     'weave-report-about-keyword)
    (define-key map "\C-c\C-n"  'weave-next-annotation)
    (define-key map "\C-c\C-p"  'weave-previous-annotation)
    map))

(define-minor-mode weave-annotation-mode
  "Toggle activating and deactivating weave-annotation related key map."
  :group 'weave
  :lighter " Weave"
  )
;;
;; (define-key global-map [(hyper ?A)] 'weave-annotate)
;; TODO force insertion


(require 'etags)
(defvar weave-original-visit-tags-table nil)
(unless (fboundp 'weave-original-visit-tags-table)
  (fset 'weave-original-visit-tags-table
	(symbol-function 'visit-tags-table)))

(defun weave-search-tags-file (base)
  (unless (equal base "/")
    (let ((upper (file-name-directory base)))
      (if (file-exists-p (concat upper "plugins/etags/TAGS"))
	  (concat upper "plugins/etags")
	(weave-search-tags-file (directory-file-name upper))))))
    
(defun weave-visit-tags-table ()
  (interactive)
  (let ((in-weave (weave-search-tags-file default-directory)))
	(let ((default-directory (or in-weave default-directory)))
	  (call-interactively 'weave-original-visit-tags-table))))

(fset 'visit-tags-table (symbol-function 'weave-visit-tags-table))
  

(provide 'weave)
