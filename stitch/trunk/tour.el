;;; tour.el --- Source code tour

;; Copyright (C) 2013 Red Hat, Inc.
;; Copyright (C) 2013 Masatake YAMATO

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

(require 'stitch)

(defvar tour-table (make-hash-table :test 'equal))
(defvar tour-current-name nil)
(defvar tour-current-tour nil)
(defvar tour-current-offset 0)

(defun tour-reset ()
  (setq tour-current-name nil
	tour-current-tour nil
	tour-current-offset 0))

(defun tour-gather-labels (lst)
  (let ((labels (list))
	(i 1))
    (while lst
      (when (listp (car lst))
	(let ((label (memq :label (car lst))))
	  (when label
	    (setq labels (cons (cons (cadr label) i) labels)))))
      (setq lst (cdr lst)
	    i (1+ i)))
    labels))
	       
(defmacro deftour (name doc body &rest spec)
  `(progn
     (put ',name 'tour-doc ,doc)
     (put ',name 'tour-labels
	  ',(tour-gather-labels body))
     (puthash ,(symbol-name name) 
	      ',(mapcar 
	       (lambda (elt)
		 (cond
		  ((symbolp elt)
		   `(annotation ,(symbol-name elt)))
		  ((stringp elt)
		   `(coverpage ,elt))
		  (t
		   elt)))
	       body)
	      tour-table)))

(defun tour-doc (tour)
  (get (intern-soft tour) 'tour-doc))

(defun tour-read ()
  (completing-read (let ((d (thing-at-point 'symbol)))
		     (if d 
			 (format "Tour(%s): " d)
		       "Tour: "))
		   tour-table
		   nil
		   t
		   nil
		   nil
		   (thing-at-point 'symbol)))
(defun tour (tour rehearsal?)
  (interactive (list (tour-read)
		     current-prefix-arg))
  (unless rehearsal?
    (tour-mode))
  (setq tour-current-name tour)
  (tour-start (gethash tour tour-table)))

(defun tour-start (tour)
  (setq tour-current-tour tour)
  (tour-goto-beginning))

(defun tour-set-and-go (n)
  (interactive "NOffset: ")
  (let ((old tour-current-offset))
    (let ((elt (nth tour-current-offset tour-current-tour)))
      (tour-get-apply-method tour-current-name old elt 'leave))
    (setq tour-current-offset n)
    (let ((elt (nth tour-current-offset tour-current-tour)))
      (tour-get-apply-method tour-current-name n elt 'enter))
    (tour-show-pos)))

(defun tour-goto-current ()
  (interactive)
  (tour-set-and-go tour-current-offset))

(defun tour-goto-beginning ()
  (interactive)
  (tour-set-and-go 0))
(defun tour-goto-end ()
  (interactive)
  (tour-set-and-go (1- (length tour-current-tour))))

(defun tour-goto-prev ()
  (interactive)
    (if (< 0 tour-current-offset)
	(tour-set-and-go (1- tour-current-offset))
      (error "beginning of tour")))

(defun tour-goto-next ()
  (interactive)
  (let ((len (length tour-current-tour)))
    (if (< (1+ tour-current-offset) len)
	(tour-set-and-go (1+ tour-current-offset))
      (error "end of tour"))))

(defun tour-format-pos ()
  (format "%s[%s/%s]" 
	  tour-current-name
	  (1+ tour-current-offset)
	  (length tour-current-tour)))
(defun tour-show-pos ()
  (interactive)
  (message "%s" (tour-format-pos)))


(defvar tour-menu (make-sparse-keymap "Tour"))
(define-key-after global-map [menu-bar tour] (cons "Tour" tour-menu))

(define-key-after tour-menu [start-tour]
  '(menu-item "Start Tour..." tour))

(define-key-after tour-menu [list-tours]
  '(menu-item "List Tours" tour-list))

(defvar tour-mode-map 
  (let ((map (make-sparse-keymap "Tour")))
    (define-key map " " 'tour-goto-next)
    (define-key map [backspace] 'tour-goto-prev)
    (define-key map "<" 'tour-goto-beginning)
    (define-key map ">" 'tour-goto-end)
    (define-key map "." 'tour-goto-current)
    (define-key map "@" 'tour-show-pos)
    (define-key map "?" 'tour-schedule)
    (define-key map "q" 'tour-quit)
    map))

(defun tour-quit ()
  (interactive)
  (when tour-mode
    (tour-reset)
    (tour-mode 'toggle)))

(defvar tour-mode-last-window-configuration nil) 
(define-minor-mode tour-mode
  "Welcome to the source code tour."
  :lighter (:eval (if tour-current-name 
		      (propertize (format " %s" (tour-format-pos))
					      'face
					      'mode-line-emphasis)
		    ""))
  :global t
  :keymap tour-mode-map
  :group 'stitch
  (if tour-mode-last-window-configuration
      (set-window-configuration
       tour-mode-last-window-configuration)
       (setq tour-mode-last-window-configuration 
	     (current-window-configuration))
       ))

(define-key global-map [(f9) (next)] 'tour-goto-next)
(define-key global-map [(f9) ?\ ] 'tour-goto-next)
(define-key global-map [(f9) (prior)] 'tour-goto-prev)
(define-key global-map [(f9) (backspace)] 'tour-goto-prev)

(define-key global-map [(f9) (home)] 'tour-goto-beginning)
(define-key global-map [(f9) (end)] 'tour-goto-end)
(define-key global-map [(f9) (f9)] 'tour-goto-current)
(define-key global-map [(f9) (return)] 'tour-goto-current)
(define-key global-map [(f9) (f1)] 'tour-show-pos)
(define-key global-map [(f9) (f10)] 'tour-schedule)

(define-key ctl-x-map    "TN"  'tour-goto-next)
(define-key ctl-x-map    "TP"  'tour-goto-prev)
(define-key ctl-x-map    "T."  'tour-goto-current)
(define-key ctl-x-map    "T>"  'tour-goto-end)
(define-key ctl-x-map    "T<"  'tour-goto-beginning)
(define-key ctl-x-map    "T?"  'tour-show-pos)
(define-key ctl-x-map    "Tl"  'tour-schedule)
(define-key ctl-x-map    "TL"  'tour-list)

(defun tour-list ()
  (interactive)
  (let ((b (get-buffer-create "*Tours List*")))
    (set-buffer b)
    (let* ((buffer-read-only  nil)
	   (l (let ((l0 nil))
		(maphash (lambda (k v) (setq l0 (cons k l0)))
			 tour-table)
		l0)))
      (erase-buffer)
      (mapc
       (lambda (tn)
	 (let* ((v (gethash tn tour-table))
		(subject (tour-doc tn)))
	   (insert (format "%s(%d): %s\n" 
			   (propertize tn 
				       'face 'stitch-keyword
				       'mouse-face 'highlight
				       'tour tn)
			   (length (gethash tn tour-table))
			   (propertize  (car (split-string subject "\n"))
					;;'face 'stitch-annotation-base
					'help-echo subject
					)
			   ))
	   ))
       l))
    (local-set-key [return]  'tour-list-tour)
    (setq buffer-read-only t)
    (goto-char (point-min))
    (hl-line-mode 1)
    (pop-to-buffer b)))

(defun tour-list-tour (rehearsal?)
  (interactive "P")
  (tour (get-text-property (point) 'tour) rehearsal?))

(defun tour-filter-uuid (tour-elt)
  (tour-get-apply-method nil 0 tour-elt 'filter-uuid))
(defun tour-filter-uuids (tour-def)
  (delete nil (mapcar #'tour-filter-uuid
		      tour-def)))

(defun tour-render-in-rst (tour-name tour-elt offset)
  (tour-get-apply-method tour-name offset tour-elt 'render-in-rst))

(defun tour-get-context-range (tour-elt)
  (let ((range (stitch-klist-value tour-elt :context)))
    (if range
	range
      '(0 7))))

(defun tour-get-overwrite (tour-elt)
  (stitch-klist-value tour-elt :overwrite))

(defun tour-schedule (read-tour?)
  (interactive "P")
  (let ((tour (if (or read-tour? (not tour-current-name))
		  (tour-read)
		tour-current-name)))
    (let* ((b (get-buffer-create (format "*Schedule: %s*" tour)))
	   (uuids (tour-filter-uuids (gethash tour tour-table)))
	   )
      (with-current-buffer b
	(let ((buffer-read-only nil))
	  (erase-buffer)
	  (insert "Tour: ")
	  (insert tour)
	  (insert "\n")
	  (insert "=============================================\n")
	  (let ((doc (tour-doc tour)))
	    (when doc
	      (insert doc)
	      (insert "\n\n")))
	  (stitch-list-annotation-with-filter b
					      (lambda (k e)
						(let ((uuid (stitch-klist-value e :uuid)))
						  (member uuid uuids)))
					      nil
					      nil
					      t))))))

;; batch
;; hyper linnk
;; cite/reference
;; index
(defun tour-rst (read-tour?)
  (interactive "P")
  (let ((tour (if (or read-tour? (not tour-current-name))
		  (tour-read)
		tour-current-name)))
    (let* ((b (get-buffer-create (format "*Rst: %s*" tour)))
	   (tour-def (gethash tour tour-table))
	   (title (tour-doc tour)))
      (with-current-buffer b
	(let ((buffer-read-only nil))
	  (erase-buffer)
	  (insert "==========================================================================================\n")
	  (insert title)
	  (insert "\n")
	  (insert "==========================================================================================\n\n")
	  (let ((i 1))
	    (mapcar  (lambda (tour-elt)
		       (insert (format "%d. %s\n" i 
				       (or (stitch-klist-value tour-elt :subject) "")))
		       (setq i (1+ i))
		       )
		     tour-def))
	  
	  (mapc (lambda (text)
		  (when text
		    (insert text)
		    ))
		(let ((i 0))
		  (mapcar  (lambda (tour-elt)
			     (let ((r (tour-render-in-rst tour tour-elt i)))
			       (setq i (1+ i))
			       (concat "\n\n"
				       (let* ((subject (or (stitch-klist-value tour-elt :subject) "")))
					 (concat 
					  title  "\n"
					  (make-string ;(* 3 (length title))
					   72
					   ?=) "\n"
					   (format "`[%d/%d]` " i (length tour-def))
					  subject "\n"
					  (make-string ;(* 3 (length subject))
					   72
					   ?-)))
				       "\n\n" r)))
			   tour-def))))
	(rst-mode)
	(goto-char (point-min))
	(pop-to-buffer b)
	b))))

(defun tour-rst-batch (name output-file kill-emacs-after-writing?)
  (tour name nil)
  (with-current-buffer (tour-rst nil)
    (write-file output-file)
    (when kill-emacs-after-writing?
      (kill-emacs 0))
    ))
  

;;
;; HANDLERS
;;
(defvar tour-handlers (make-hash-table :test 'eq))
(defun tour-get-handler (type)
  (gethash type tour-handlers nil))
(defun tour-register-handler (type handler)
  (puthash type handler tour-handlers))
(defun tour-get-apply-method (name offset elt method)
  (let ((handler (tour-get-handler (car elt))))
    (unless handler
      (error "unknown handler: %s" (car elt)))
    (let ((m (assq method handler)))
      (when m
	(funcall (cdr m) name offset (car elt) (cdr elt))))))

;;
;; Annotation
;;
(defun tour-annotation-enter (name offset k rest)
  (stitch-jump-to-uuid (car rest))
  (recenter 1))
(defun tour-annotation-leave (name offset k rest)
  )

(defun tour-annotation-filter-uuid (name offset k rest)
  (nth 0 rest))

(defun tour-build-string (tree)
  (apply #'concat
	 (mapcar
	  (lambda (elt)
	    (if (stringp elt)
		elt
	      (tour-build-string elt)))
	  tree)))

(defun tour-rst-lang-for-file (file)
  (let ((ext (file-name-extension file)))
    (cond
     ((equal ext "h") "c")
     (t ext))))

(defun tour-fill-string (a)
  (with-temp-buffer
    (rst-mode)
    (insert a)
    (set-fill-column 50)
    (fill-region (point-min) (point-max))
    (buffer-string)
    ))

(defun tour-annotation-render-in-rst (name offset k rest)
  (let* ((elt rest)
	 (uuid (tour-annotation-filter-uuid name offset k elt)))
    (let* ((context-range (tour-get-context-range elt))
	   (line- (car context-range))
	   (line+ (cadr context-range))
	   (entry (stitch-get-annotation-by-uuid uuid))
	   (target (stitch-klist-value entry :target))
	   (file  (car (stitch-target-get-files target)))
	   (lang (tour-rst-lang-for-file file))
	   (line (stitch-klist-value target :line))
	   (a (or (tour-get-overwrite elt)
		  (stitch-list-render-annotation file entry)))
	   (c (stitch-list-render-context file entry
					  line- line+
					  ""
					  nil)))
      ;;
      (tour-build-string
       (list 
	(tour-fill-string a)
	"\n"
	(let ((file-short (cond
			   ((string-match "^/srv/sources/sources/[0-9a-zA-Z]/\\(.*\\)" 
					  file)
			    (match-string 1 file))
			   (t
			    file)))
	      (func (stitch-klist-value target :which-func)))
	  (list 
	    "Function\n	" func
	    "\n"
	    "File\n	" file-short
	    "\n"
	    ;; "Line\n	" (format "%d" line)
 	   ;;(format "*%s@%s:%d*:\n\n" func file line)
	    "\n"
 	   )
	  )
	(if lang
	    (list
	     (format ".. code-block:: %s\n" lang)
	     "	:linenos:\n"
	     (format "	:linenos_offset: %d\n" (- line 1))
	     )
	  "::")
	"\n         \n"
	(mapcar 
	 (lambda (s) 
	   (list "        "
		 s
		 "\n"))
	 (split-string c "\n"))
	"\n"
	)))))


(defconst tour-annotation-handler '((enter . tour-annotation-enter)
				    (leave . tour-annotation-leave)
				    (filter-uuid . tour-annotation-filter-uuid)
				    (render-in-rst . tour-annotation-render-in-rst)
				    ))

;;
;; Coverpage
;;
(defvar tour-coverpage-buffer nil)
(defun tour-coverpage-build-text (name rest)
  (with-temp-buffer
    (insert (car rest))
    (goto-char (point-min))
    (tour-coverpage-render-labels
     (get (intern-soft name) 'tour-labels))
    (buffer-string)))
     
(defun tour-coverpage-render-labels (labels)
  (while labels
    (save-excursion
      (goto-char (point-min))
      (replace-string (concat "[" (car (car labels)) "]")
		      (concat "[" (format "%d" (cdr (car labels))) "]"))
      (setq labels (cdr labels)))))
(defun tour-coverpage-enter (name offset k rest)
  (setq tour-coverpage-buffer (get-buffer-create "*Tour Coverpage*"))
  (with-current-buffer tour-coverpage-buffer
    (setq buffer-read-only t)
    (let ((buffer-read-only nil))
      (erase-buffer)
      (insert (tour-coverpage-build-text name rest))
      ))
  (switch-to-buffer tour-coverpage-buffer))

(defun tour-coverpage-leave (name offset k rest)
  )
  
(defun tour-converpage-render-in-rst (name offset k rest)
  (tour-fill-string (tour-coverpage-build-text name rest))
  )

(defconst tour-coverpage-handler '((enter . tour-coverpage-enter)
				   (leave . tour-coverpage-leave)
				   (render-in-rst . tour-converpage-render-in-rst)))

  
(tour-register-handler 'annotation  tour-annotation-handler)
(tour-register-handler 'A           tour-annotation-handler)
(tour-register-handler 'coverpage   tour-coverpage-handler)
(tour-register-handler 'C           tour-coverpage-handler)

;; (deftour test
;;   (
;;    16200dcc1ad6eac343b5b68b0ffc6a3e90b0db13
;;    76ad367c131edb512f3e66bbc5f20ea0a4b09a3b
;;    bf7acdccee46f610a0c8bc67f090d8d9fffa82d2
;;    )
;;   "ツアー機能を追加したので、その試しである。
;; など。")

;; (define-key global-map [f8] 'conv-id)
;; (defun conv-id ()
;;   (interactive)
;;   (save-excursion
;;     (let* ((b (progn (backward-sexp 1) (point)))
;; 	   (e (progn (forward-sexp 1) (point)))
;; 	   (id (buffer-substring b e))
;; 	   (uuid (let ((entry (gethash id stitch-ids nil)   ))
;; 		   (stitch-klist-value entry :uuid))))
;;       (goto-char b)
;;       (insert uuid)
;;       (insert " ; "))))

(define-derived-mode tour-edit-mode emacs-lisp-mode "Tour-Edit"
  "Major mode for editing a tour."
  (define-key tour-edit-mode-map "\M-." 'stitch-jump-to-uuid)
  (define-key tour-edit-mode-map "\C-c\C-f" 'stitch-jump-to-home-by-uuid)
  (define-key tour-edit-mode-map "\C-\M-x" 'eval-defun)
  (set (make-variable-buffer-local 'file-of-tag-function)
       'tour-file-of-tag)
  (add-hook 'find-tag-hook
	    (lambda ()
	      (unless (memq 'tour-tag-uuid find-tag-tag-order)
		(setq find-tag-tag-order (cons 'tour-tag-uuid find-tag-tag-order))))))

(defun tour-tag-uuid (uuid)
  (if (string-match "^[0-9a-f]\\{8\\}-[0-9a-f]\\{4\\}-[0-9a-f]\\{4\\}-[0-9a-f]\\{4\\}-[0-9a-f]\\{12\\}$" 
		    uuid)
      (progn
	(stitch-jump-to-uuid (intern-soft uuid))
	t)
    nil))

(defun tour-find-tag ()
  (thing-at-point 'symbol))

(defun tour-file-of-tag (uuid)
  (save-excursion
    (stitch-jump-to-uuid (intern-soft uuid)))
    (buffer-file-name))

(put 'tour-edit-mode
     'find-tag-default-function
     'tour-find-tag)

(provide 'tour)
