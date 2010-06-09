;;; xhtmlize-engine.el -- Core part of xhtmlize.el
;;
;; Copyright (C) 2009,2010 Masatake YAMATO
;; Copyright (C) 1997,1998,1999,2000,2001,2002,2003,2005,2006 Hrvoje Niksic
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;; This program is mostly derived from htmlize.el written by 
;; Hrvoje Niksic <hniksic@xemacs.org>.
;; The latest version of htmlize.el should be available at:
;;
;;        <http://fly.srk.fer.hr/~hniksic/emacs/xhtmlize.el>
;;
;; You can find a sample of htmlize's output (possibly generated with
;; an older version) at:
;;
;;        <http://fly.srk.fer.hr/~hniksic/emacs/xhtmlize.el.html>
(require 'xhtmlize)

(defclass <xhtmlize-engine> (<xhtmlize-common-engine>)
  ()
  )
(define-xhtmlize-engine nil <xhtmlize-engine>)
(define-xhtmlize-engine 'xhtmlize <xhtmlize-engine>)

(defmethod xhtmlize-engine-prepare ((engine <xhtmlize-engine>))
  (call-next-method)
  (oset engine 
	canvas (generate-new-buffer (if (buffer-file-name)
					(xhtmlize-make-file-name
					 (file-name-nondirectory
					  (buffer-file-name)))
				      "*html*"))))

(defmethod xhtmlize-engine-prologue ((engine <xhtmlize-engine>) title)
  (with-current-buffer (oref engine canvas)
    (buffer-disable-undo)
    ;; NEW CODE
    (insert "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" ?\n)
    ;;
    (insert (xhtmlize-method doctype) ?\n
	    (format "<!-- Created by xhtmlize-%s in %s mode. -->\n"
		    xhtmlize-version xhtmlize-output-type)
	    ;; HTMLIZE.EL
	    ;; "<html>\n  "
	    ;; XHTMLIZE.EL
	    "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">"
	    
	    ?\n)
    (plist-put (oref engine places) 'head-start (point-marker))
    ;;
    (insert "<head>" ?\n)
    ;;
    (insert "    <title>" (xhtmlize-protect-string title) "</title>\n"
	    (if xhtmlize-html-charset
		(format (concat "    <meta http-equiv=\"Content-Type\" "
				"content=\"text/html; charset=%s\">\n")
			xhtmlize-html-charset)
	      "")
	    xhtmlize-head-tags)
    (xhtmlize-method insert-head (oref engine buffer-faces) (oref engine face-map))
    (insert "  </head>")
    (plist-put (oref engine places) 'head-end (point-marker))
    (insert "\n  ")
    (plist-put (oref engine places) 'body-start (point-marker))
    (insert (xhtmlize-method body-tag (oref engine face-map))
	    "\n    ")
    (plist-put (oref engine places) 'content-start (point-marker))
    (insert xhtmlize-body-pre-tags)
    (insert "<pre>\n")))

(defmethod xhtmlize-engine-body ((engine <xhtmlize-engine>))
  (with-slots (canvas face-map) engine
    (let (;; Get the inserter method, so we can funcall it inside
	  ;; the loop.  Not calling `xhtmlize-method' in the loop
	  ;; body yields a measurable speed increase.
	  (insert-text-with-id-method
	   (xhtmlize-method-function 'insert-text-with-id))
	  ;; Declare variables used in loop body outside the loop
	  ;; because it's faster to establish `let' bindings only
	  ;; once.
	  next-change text face-list fstruct-list trailing-ellipsis)
      ;; This loop traverses and reads the source buffer, appending
      ;; the resulting HTML to HTMLBUF with `princ'.  This method is
      ;; fast because: 1) it doesn't require examining the text
      ;; properties char by char (xhtmlize-next-change is used to
      ;; move between runs with the same face), and 2) it doesn't
      ;; require buffer switches, which are slow in Emacs.
      (goto-char (point-min))
      (while (not (eobp))
	(mapc (lambda (o)
		(xhtmlize-width0-overlay o 
					 insert-text-with-id-method
					 face-map
					 canvas)
		)
	      (xhtmlize-overlays-at (point)))
	
	(setq next-change (xhtmlize-next-change (point) 'face))
	;; Get faces in use between (point) and NEXT-CHANGE, and
	;; convert them to fstructs.
	(setq face-list (xhtmlize-faces-at-point)
	      fstruct-list (delq nil (mapcar (lambda (f)
					       (gethash f face-map))
					     face-list)))
	;; Extract buffer text, sans the invisible parts.  Then
	;; untabify it and escape the HTML metacharacters.
	(setq text (xhtmlize-buffer-substring-no-invisible
		    (point) next-change))
	(when trailing-ellipsis
	  (setq text (xhtmlize-trim-ellipsis text)))
	;; If TEXT ends up empty, don't change trailing-ellipsis.
	(when (> (length text) 0)
	  (setq trailing-ellipsis
		(get-text-property (1- (length text))
				   'xhtmlize-ellipsis text)))
	(setq text (xhtmlize-untabify text (current-column)))
	(setq text (xhtmlize-protect-string text))
	;; Don't bother writing anything if there's no text (this
	;; happens in invisible regions).
	(when (> (length text) 0)
	  ;; Insert the text, along with the necessary markup to
	  ;; represent faces in FSTRUCT-LIST.
	  (funcall insert-text-with-id-method text 
					;(format "font-lock:%s" (point))
		   (concat "F:" (number-to-string (point)))
		   nil
		   fstruct-list
		   canvas))
	(goto-char next-change)))))

(defmethod xhtmlize-engine-epilogue ((engine <xhtmlize-engine>))
  (with-current-buffer (oref engine canvas)
    (insert "</pre>")
    (insert xhtmlize-body-post-tags)
    (plist-put (oref engine places) 'content-end (point-marker))
    (insert "\n  </body>")
    (plist-put (oref engine places) 'body-end (point-marker))
    (insert "\n</html>\n")
    (when xhtmlize-generate-hyperlinks
      (xhtmlize-make-hyperlinks))
    (xhtmlize-defang-local-variables)
    (when xhtmlize-replace-form-feeds
      ;; Change each "\n^L" to "<hr />".
      (goto-char (point-min))
      (let ((source
	     ;; ^L has already been escaped, so search for that.
	     (xhtmlize-protect-string "\n\^L"))
	    (replacement
	     (if (stringp xhtmlize-replace-form-feeds)
		 xhtmlize-replace-form-feeds
	       "</pre><hr /><pre>")))
	(while (search-forward source nil t)
	  (replace-match replacement t t))))
    (goto-char (point-min))
    (when xhtmlize-html-major-mode
      ;; What sucks about this is that the minor modes, most notably
      ;; font-lock-mode, won't be initialized.  Oh well.
      (funcall xhtmlize-html-major-mode))
    (set (make-local-variable 'xhtmlize-buffer-places) (oref engine places))
    (run-hooks 'xhtmlize-after-hook)
    (buffer-enable-undo)))

(defmethod xhtmlize-engine-process ((engine <xhtmlize-engine>))
  (oref engine canvas))

(defvar xhtmlize-width0-overlay-temp-buffer (let ((b (get-buffer-create
							  " *width0-overlay-xhtmlize*")))
						  (with-current-buffer b
						    (buffer-disable-undo))
						  b))

(defun xhtmlize-width0-overlay (o insert-method face-map htmlbuf)
  (let ((handler (xhtmlize-width0-overlay-acceptable-p o)))
    (when handler
      ;;
      (unless (xhtmlize-width0-overlay-render-direct o
						     handler
						     insert-method
						     face-map
						     htmlbuf)
	(let ((s (xhtmlize-width0-overlay-prepare o handler)))
	  ;; TODO: Don't use `with-current-buffer'.
	  (with-current-buffer xhtmlize-width0-overlay-temp-buffer
	    (erase-buffer) 
	    (when s (insert s))
	    (xhtmlize-buffer-0 o handler insert-method face-map htmlbuf))))
      ;;
      )))

(defun xhtmlize-buffer-0 (o handler insert-method face-map htmlbuf)
  (let (next-change face-list fstruct-list text trailing-ellipsis)
    (goto-char (point-min))
    (while (not (eobp))
      (setq next-change (xhtmlize-next-change (point) 'face))
      (setq face-list (xhtmlize-faces-at-point)
	    fstruct-list (delq nil (mapcar (lambda (f)
					     (gethash f face-map))
					   face-list)))
      (setq text (xhtmlize-buffer-substring-no-invisible
		  (point) next-change))
      
;;      (when trailing-ellipsis
;;	(setq text (xhtmlize-trim-ellipsis text)))
;;      (when (> (length text) 0)
;;	(setq trailing-ellipsis
;;	      (get-text-property (1- (length text))
;;				 'xhtmlize-ellipsis text)))
      (setq text (xhtmlize-untabify text (current-column)))
      (setq text (xhtmlize-protect-string text))
      (when (> (length text) 0)
	;; Insert the text, along with the necessary markup to
	;; represent faces in FSTRUCT-LIST.
	(funcall insert-method
		 text
		 (xhtmlize-width0-overlay-make-id o handler)
		 (xhtmlize-width0-overlay-make-href o handler)
		 fstruct-list htmlbuf))
      (goto-char next-change))
    ))

(provide 'xhtmlize-engine)
