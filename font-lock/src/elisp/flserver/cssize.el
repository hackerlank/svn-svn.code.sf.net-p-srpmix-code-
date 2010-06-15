;;; cssize.el -- Convert face to CSS.
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

;; This program is derived from htmlize.el written by 
;; Hrvoje Niksic <hniksic@xemacs.org>.

(eval-and-compile 
  (require 'cl))


(defgroup cssize nil
  "Convert a face to CSS."
  :group 'hypermedia)

(defcustom cssize-css-name-prefix ""
  "*The prefix used for CSS names.
The CSS names that cssize generates from face names are often too
generic for CSS files; for example, `font-lock-type-face' is transformed
to `type'.  Use this variable to add a prefix to the generated names.
The string \"cssize-\" is an example of a reasonable prefix."
  :type 'string
  :group 'cssize)

(defcustom cssize-use-rgb-txt t
  "*Whether `rgb.txt' should be used to convert color names to RGB.

This conversion means determining, for instance, that the color
\"IndianRed\" corresponds to the (205, 92, 92) RGB triple.  `rgb.txt'
is the X color database that maps hundreds of color names to such RGB
triples.  When this variable is non-nil, `cssize' uses `rgb.txt' to
look up color names.

If this variable is nil, cssize queries Emacs for RGB components of
colors using `color-instance-rgb-components' and `x-color-values'.
This can yield incorrect results on non-true-color displays.

If the `rgb.txt' file is not found (which will be the case if you're
running Emacs on non-X11 systems), this option is ignored."
  :type 'boolean
  :group 'cssize)

(defcustom cssize-ignore-face-size 'absolute
  "*Whether face size should be ignored when generating HTML.
If this is nil, face sizes are used.  If set to t, sizes are ignored
If set to `absolute', only absolute size specifications are ignored.
Please note that font sizes only work with CSS-based output types."
  :type '(choice (const :tag "Don't ignore" nil)
		 (const :tag "Ignore all" t)
		 (const :tag "Ignore absolute" absolute))
  :group 'cssize)

(defconst cssize-running-xemacs (string-match "XEmacs" emacs-version))


;; We store the face properties we care about into an
;; `cssize-fstruct' type.  That way we only have to analyze face
;; properties, which can be time consuming, once per each face.  The
;; mapping between Emacs faces and cssize-fstructs is established by
;; cssize-make-face-map.  The name "fstruct" refers to variables of
;; type `cssize-fstruct', while the term "face" is reserved for Emacs
;; faces.

(defvar cssize-pseudo-face-attr-table (make-hash-table :test 'eq))
(defmacro define-cssize-pseudo-face-attr-table (face attrs)
  `(setf (gethash (quote ,face) cssize-pseudo-face-attr-table) (quote ,attrs)))

(defstruct cssize-fstruct
  foreground				; foreground color, #rrggbb
  background				; background color, #rrggbb
  size					; size
  boldp					; whether face is bold
  italicp				; whether face is italic
  underlinep				; whether face is underlined
  overlinep				; whether face is overlined
  strikep				; whether face is struck through
  css-name				; CSS name of face
  float					; float, extra slot
  )

(defun cssize-face-to-fstruct (face)
  "Convert Emacs face FACE to fstruct."
  (let* ((fstruct (make-cssize-fstruct
		   :foreground (cssize-color-to-rgb
				(cssize-face-foreground face))
		   :background (cssize-color-to-rgb
				(cssize-face-background face))
		   :float (cdr (assq 'float 
				     (gethash face cssize-pseudo-face-attr-table nil))))))
    (dolist (attr '(:weight :slant :underline :overline :strike-through))
      (let ((value (face-attribute face attr nil t)))
	(when (and value (not (eq value 'unspecified)))
	  (cssize-face-emacs21-attr fstruct attr value))))
    (let ((size (cssize-face-size face)))
      (unless (eql size 1.0)		; ignore non-spec
	(setf (cssize-fstruct-size fstruct) size)))
    ;; Generate the css-name property.  Emacs places no restrictions
    ;; on the names of symbols that represent faces -- any characters
    ;; may be in the name, even ^@.  We try hard to beat the face name
    ;; into shape, both esthetically and according to CSS1 specs.
    (setf (cssize-fstruct-css-name fstruct)
	  (let ((name (downcase (symbol-name face))))
	    (when (string-match "\\`font-lock-" name)
	      ;; Change font-lock-FOO-face to FOO.
	      (setq name (replace-match "" t t name)))
	    (when (string-match "-face\\'" name)
	      ;; Drop the redundant "-face" suffix.
	      (setq name (replace-match "" t t name)))
	    (while (string-match "[^-a-zA-Z0-9]" name)
	      ;; Drop the non-alphanumerics.
	      (setq name (replace-match "X" t t name)))
	    (when (string-match "\\`[-0-9]" name)
	      ;; CSS identifiers may not start with a digit.
	      (setq name (concat "X" name)))
	    ;; After these transformations, the face could come
	    ;; out empty.
	    (when (equal name "")
	      (setq name "face"))
	    ;; Apply the prefix.
	    (setq name (concat cssize-css-name-prefix name))
	    name))
    fstruct))


(defun cssize-face-color-internal (face fg)
  ;; Used only under GNU Emacs.  Return the color of FACE, but don't
  ;; return "unspecified-fg" or "unspecified-bg".  If the face is
  ;; `default' and the color is unspecified, look up the color in
  ;; frame parameters.
  (let* ((function (if fg #'face-foreground #'face-background))
	 color)
    (setq color (funcall function face nil t))
    (when (and (eq face 'default) (null color))
      (setq color (cdr (assq (if fg 'foreground-color 'background-color)
			     (frame-parameters)))))
    (when (or (eq color 'unspecified)
	      (equal color "unspecified-fg")
	      (equal color "unspecified-bg"))
      (setq color nil))
    (when (and (eq face 'default)
	       (null color))
      ;; Assuming black on white doesn't seem right, but I can't think
      ;; of anything better to do.
      (setq color (if fg "black" "white")))
    color))

(defun cssize-face-foreground (face)
  ;; Return the name of the foreground color of FACE.  If FACE does
  ;; not specify a foreground color, return nil.
  (cssize-face-color-internal face t))

(defun cssize-face-background (face)
  ;; Return the name of the background color of FACE.  If FACE does
  ;; not specify a background color, return nil.
  (cssize-face-color-internal face nil))

;; Convert COLOR to the #RRGGBB string.  If COLOR is already in that
;; format, it's left unchanged.
(defvar cssize-color-rgb-hash nil)
(defun cssize-color-to-rgb (color)
  (let ((rgb-string nil))
    (cond ((null color)
	   ;; Ignore nil COLOR because it means that the face is not
	   ;; specifying any color.  Hence (cssize-color-to-rgb nil)
	   ;; returns nil.
	   )
	  ((string-match "\\`#" color)
	   ;; The color is already in #rrggbb format.
	   (setq rgb-string color))
	  ((and cssize-use-rgb-txt
		cssize-color-rgb-hash)
	   ;; Use of rgb.txt is requested, and it's available on the
	   ;; system.  Use it.
	   (setq rgb-string (gethash (downcase color) cssize-color-rgb-hash)))
	  (t
	   ;; We're getting the RGB components from Emacs.
	   (let ((rgb
		  (mapcar (lambda (arg)
			      (/ arg 256))
			    (x-color-values color))))
	     (when rgb
	       (setq rgb-string (apply #'format "#%02x%02x%02x" rgb))))))
    ;; If RGB-STRING is still nil, it means the color cannot be found,
    ;; for whatever reason.  In that case just punt and return COLOR.
    ;; Most browsers support a decent set of color names anyway.
    (or rgb-string color)))

(defun cssize-face-emacs21-attr (fstruct attr value)
  ;; For ATTR and VALUE, set the equivalent value in FSTRUCT.
  (case attr
    (:foreground
     (setf (cssize-fstruct-foreground fstruct) (cssize-color-to-rgb value)))
    (:background
     (setf (cssize-fstruct-background fstruct) (cssize-color-to-rgb value)))
    (:height
     (setf (cssize-fstruct-size fstruct) value))
    (:weight
     (when (string-match (symbol-name value) "bold")
       (setf (cssize-fstruct-boldp fstruct) t)))
    (:slant
     (setf (cssize-fstruct-italicp fstruct) (or (eq value 'italic)
						 (eq value 'oblique))))
    (:bold
     (setf (cssize-fstruct-boldp fstruct) value))
    (:italic
     (setf (cssize-fstruct-italicp fstruct) value))
    (:underline
     (setf (cssize-fstruct-underlinep fstruct) value))
    (:overline
     (setf (cssize-fstruct-overlinep fstruct) value))
    (:strike-through
     (setf (cssize-fstruct-strikep fstruct) value))))

;(defun cssize-face-size (face)
;  ;; The size (height) of FACE, taking inheritance into account.
;  ;; Only works in Emacs 21 and later.
;  (let ((size-list
;	 (loop
;	  for f = face then (face-attribute f :inherit)
;	  until (or (not f) (eq f 'unspecified))
;	  for h = (if (symbolp f)
;		      (face-attribute f :height) 
;		    (mapcar (lambda (f0)
;			      (face-attribute f0 :height))
;			    f))
;	  collect (if (eq h 'unspecified) nil h))))
;    (reduce 'cssize-merge-size (cons nil size-list))))

;; NEW CODE for linum
(defun cssize-util-uniq (input output)
  (cond
   ((null input)
    output)
   (t
    (cssize-util-uniq (cdr input)
		       (if (memq (car input) output)
			   output
			 (cons (car input) output))))))

;; NEW CODE for linum
(defun cssize-face-all-ancestors (face)
  (reverse
   (cssize-util-uniq
    (delete nil (let ((parents (face-attribute face :inherit)))
		  (cond 
		   ((or (not parents) (eq parents 'unspecified))
		    (list face))
		   ((symbolp parents)
		    (cons face (cons parents (cssize-face-all-ancestors parents))))
		   ((listp parents)
		    (apply 'append (cons face parents)
			   (mapcar 'cssize-face-all-ancestors
				   parents)))
		   (t
		    (list 'default)))))
    (list))))

;; NEW CODE for linum
(defun cssize-face-size (face)
  (reduce 'cssize-merge-size
	  (cons nil
		(delete nil (mapcar
			     (lambda (f)
			       (let ((h (face-attribute f :height)))
				 (if (or (not h) (eq h 'unspecified))
				     nil
				   h)))
			     (cssize-face-all-ancestors face))))))

(defun cssize-merge-size (merged next)
  ;; Calculate the size of the merge of MERGED and NEXT.
  (cond ((null merged)     next)
	((integerp next)   next)
	((null next)       merged)
	((floatp merged)   (* merged next))
	((integerp merged) (round (* merged next)))))


;;; Color handling.
(defalias 'cssize-locate-file 'locate-file)
(if (fboundp 'locate-file)
    
  (defun cssize-locate-file (file path)
    (dolist (dir path nil)
      (when (file-exists-p (expand-file-name file dir))
	(return (expand-file-name file dir))))))

(defvar cssize-x-library-search-path
  '("/usr/X11R6/lib/X11/"
    "/usr/X11R5/lib/X11/"
    "/usr/lib/X11R6/X11/"
    "/usr/lib/X11R5/X11/"
    "/usr/local/X11R6/lib/X11/"
    "/usr/local/X11R5/lib/X11/"
    "/usr/local/lib/X11R6/X11/"
    "/usr/local/lib/X11R5/X11/"
    "/usr/X11/lib/X11/"
    "/usr/lib/X11/"
    "/usr/local/lib/X11/"
    "/usr/X386/lib/X11/"
    "/usr/x386/lib/X11/"
    "/usr/XFree86/lib/X11/"
    "/usr/unsupported/lib/X11/"
    "/usr/athena/lib/X11/"
    "/usr/local/x11r5/lib/X11/"
    "/usr/lpp/Xamples/lib/X11/"
    "/usr/openwin/lib/X11/"
    "/usr/openwin/share/lib/X11/"))

(defun cssize-get-color-rgb-hash (&optional rgb-file)
  "Return a hash table mapping X color names to RGB values.
The keys in the hash table are X11 color names, and the values are the
#rrggbb RGB specifications, extracted from `rgb.txt'.

If RGB-FILE is nil, the function will try hard to find a suitable file
in the system directories.

If no rgb.txt file is found, return nil."
  (let ((rgb-file (or rgb-file (cssize-locate-file
				"rgb.txt"
				cssize-x-library-search-path)))
	(hash nil))
    (when rgb-file
      (with-temp-buffer
	(insert-file-contents rgb-file)
	(setq hash (make-hash-table :test 'equal))
	(while (not (eobp))
	  (cond ((looking-at "^\\s-*\\([!#]\\|$\\)")
		 ;; Skip comments and empty lines.
		 )
		((looking-at
		  "[ \t]*\\([0-9]+\\)[ \t]+\\([0-9]+\\)[ \t]+\\([0-9]+\\)[ \t]+\\(.*\\)")
		 (setf (gethash (downcase (match-string 4)) hash)
		       (format "#%02x%02x%02x"
			       (string-to-number (match-string 1))
			       (string-to-number (match-string 2))
			       (string-to-number (match-string 3)))))
		(t
		 (error
		  "Unrecognized line in %s: %s"
		  rgb-file
		  (buffer-substring (point) (progn (end-of-line) (point))))))
	  (forward-line 1))))
    hash))

;; Compile the RGB map when loaded.  On systems where rgb.txt is
;; missing, the value of the variable will be nil, and rgb.txt will
;; not be used.
(setq cssize-color-rgb-hash (cssize-get-color-rgb-hash))


;; Internal function; not a method.
(defun cssize-css-specs (fstruct)
  (let (result)
    (when (cssize-fstruct-foreground fstruct)
      (push (format "color: %s;" (cssize-fstruct-foreground fstruct))
	    result))
    (when (cssize-fstruct-background fstruct)
      (push (format "background-color: %s;"
		    (cssize-fstruct-background fstruct))
	    result))
    (let ((size (cssize-fstruct-size fstruct)))
      (when (and size (not (eq cssize-ignore-face-size t)))
	(cond ((floatp size)
	       (push (format "font-size: %d%%;" (* 100 size)) result))
	      ((not (eq cssize-ignore-face-size 'absolute))
	       (push (format "font-size: %spt;" (/ size 10.0)) result)))))
    (when (cssize-fstruct-boldp fstruct)
      (push "font-weight: bold;" result))
    (when (cssize-fstruct-italicp fstruct)
      (push "font-style: italic;" result))
    (when (cssize-fstruct-underlinep fstruct)
      (push "text-decoration: underline;" result))
    (when (cssize-fstruct-overlinep fstruct)
      (push "text-decoration: overline;" result))
    (when (cssize-fstruct-strikep fstruct)
      (push "text-decoration: line-through;" result))
    (let ((float (cssize-fstruct-float fstruct)))
      (when float
	(push (format "float: %s;" float) result)))
    (nreverse result)))

(defun cssize-clean-up-face-name (face)
  (let ((s (with-temp-buffer 
	     ;; Use `prin1-to-string' rather than `symbol-name'
	     ;; to get the face name because the "face" can also
	     ;; be an attrlist, which is not a symbol.
	     (prin1-to-string face))))
    ;; If the name contains `--' or `*/', remove them.
    (while (string-match "--" s)
      (setq s (replace-match "-" t t s)))
    (while (string-match "\\*/" s)
      (setq s (replace-match "XX" t t s)))
    ;; This is needed to use the face name as a file name.
    (while (string-match "/" s)
      (setq s (replace-match "." t t s)))
    s))

(defvar cssize-default-a-css 
  "a { color: inherit; background-color: inherit; font: inherit; text-decoration: inherit; }\n")
(defun cssize-face-to-css (face &optional name)
  (let* ((fstruct (cssize-face-to-fstruct face))
	 (cleaned-up-face-name (cssize-clean-up-face-name face))
	 (specs (cssize-css-specs fstruct)))
    (concat 
     (cond
      ((and (eq face 'default) (not name))
       (cssize-face-to-css face "body"))
      ((and (eq face 'highlight) (not name))
       (concat 
	cssize-default-a-css 
	(cssize-face-to-css face "a:hover")))
      (t
	 ""))
     (format "/* About copyright see %s */\n"
	     (cond
	      ((fboundp 'describe-simplify-lib-file-name)
	       (describe-simplify-lib-file-name (symbol-file face 'defface)))
	      (t
	       (let ((file (find-lisp-object-file-name face 'face)))
		 (if (eq file 'C-source)
		     "c source code of GNU Emacs"
		   file)))
	     ))
     ;; 
     (if name name (concat "." (cssize-fstruct-css-name fstruct)))
     (if (null specs)
	 " {"
       (concat " {\n        /* " cleaned-up-face-name " */\n        "))
     (mapconcat #'identity specs "\n        ")
     "\n}\n"
     ;;
     )))

(defun cssize-file (face file)
  "Convet FACE to css and write it to FILE"
  (save-excursion
    (let ((buffer  (find-file-noselect file)))
      (with-current-buffer buffer
	(buffer-disable-undo)
	(erase-buffer)
	(insert (cssize-face-to-css face))
	(save-buffer))
      (kill-buffer buffer))))

(provide 'cssize)
