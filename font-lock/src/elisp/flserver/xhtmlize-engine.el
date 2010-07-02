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
				      "*xhtml*"))))

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
    (xhtmlize-method insert-head
		     (oref engine buffer-faces)
		     (oref engine face-map)
		     )
    (insert "  </head>")
    (plist-put (oref engine places) 'head-end (point-marker))
    (insert "\n  ")
    ))

(defmethod xhtmlize-engine-body ((engine <xhtmlize-engine>))
  (with-current-buffer (oref engine canvas)
    (plist-put (oref engine places) 'body-start (point-marker))
    (insert (xhtmlize-method body-tag (oref engine face-map))
	    "\n    ")
    (plist-put (oref engine places) 'content-start (point-marker))
    (insert xhtmlize-body-pre-tags)
    (insert "<pre>\n"))
  (xhtmlize-engine-body-common engine
			       ;; Get the inserter method, so we can funcall it inside
			       ;; the loop.  Not calling `xhtmlize-method' in the loop
			       ;; body yields a measurable speed increase.
			       (xhtmlize-method-function 'insert-text-with-id))
  (with-current-buffer (oref engine canvas)
    (insert "</pre>")
    (insert xhtmlize-body-post-tags)
    (plist-put (oref engine places) 'content-end (point-marker))
    (insert "\n  </body>")
    (plist-put (oref engine places) 'body-end (point-marker))))

(defmethod xhtmlize-engine-epilogue ((engine <xhtmlize-engine>))
  (with-current-buffer (oref engine canvas)
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

(defmethod xhtmlize-engine-make-file-name ((engine <xhtmlize-engine>) file)
  "Make an HTML file name from FILE.

In its default implementation, this simply appends `.html' to FILE.
This function is called by xhtmlize to create the buffer file name, and
by `xhtmlize-file' to create the target file name.

More elaborate transformations are conceivable, such as changing FILE's
extension to `.html' (\"file.c\" -> \"file.html\").  If you want them,
overload this function to do it and xhtmlize will comply."
  (concat file ".html"))


;; Older implementation of xhtmlize-make-file-name that changes FILE's
;; extension to ".html".
;(defun xhtmlize-make-file-name (file)
;  (let ((extension (file-name-extension file))
;	(sans-extension (file-name-sans-extension file)))
;    (if (or (equal extension "html")
;	    (equal extension "htm")
;	    (equal sans-extension ""))
;	(concat file ".html")
;      (concat sans-extension ".html"))))




(provide 'xhtmlize-engine)
