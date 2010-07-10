;;; xhtmlize.el -- Convert buffer text and decorations to XHTML.
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


;;; Code:

(require 'cl)
(require 'cssize)
(require 'assoc)
(require 'eieio)
(require 'log)				;TODO

(eval-when-compile
  (defvar font-lock-auto-fontify)
  (defvar font-lock-support-mode)
  (defvar global-font-lock-mode))

(defconst xhtmlize-version "1.34.1")

(defgroup xhtmlize nil
  "Convert buffer text and faces to HTML."
  :group 'hypermedia)

(defcustom xhtmlize-head-tags ""
  "*Additional tags to insert within HEAD of the generated document."
  :type 'string
  :group 'xhtmlize)

(defcustom xhtmlize-body-pre-tags ""
  "*Additional tags to insert within head of BODY of the generated document."
  :type 'string
  :group 'xhtmlize)

(defcustom xhtmlize-body-post-tags ""
  "*Additional tags to insert within tail of BODY of the generated document."
  :type 'string
  :group 'xhtmlize)

(defcustom xhtmlize-output-type 'external-css
  "*Output type of generated HTML, one of `css', `inline-css', or `font'.
When set to `css' (the default), xhtmlize will generate a style sheet
with description of faces, and use it in the HTML document, specifying
the faces in the actual text with <span class=\"FACE\">.

When set to `inline-css', the style will be generated as above, but
placed directly in the STYLE attribute of the span ELEMENT: <span
style=\"STYLE\">.  This makes it easier to paste the resulting HTML to
other documents.

When set to `font', the properties will be set using layout tags
<font>, <b>, <i>, <u>, and <strike>.

`css' output is normally preferred, but `font' is still useful for
supporting old, pre-CSS browsers, and both `inline-css' and `font' for
easier embedding of colorized text in foreign HTML documents (no style
sheet to carry around)."
  :type '(choice (const external-css) 
		 (const css)
		 (const inline-css)
		 (const font))
  :group 'xhtmlize)

(defcustom xhtmlize-generate-hyperlinks t
  "*Non-nil means generate the hyperlinks for URLs and mail addresses.
This is on by default; set it to nil if you don't want xhtmlize to
insert hyperlinks in the resulting HTML.  (In which case you can still
do your own hyperlinkification from xhtmlize-after-hook.)"
  :type 'boolean
  :group 'xhtmlize)

(defcustom xhtmlize-hyperlink-style "
      a {
        color: inherit;
        background-color: inherit;
        font: inherit;
        text-decoration: inherit;
      }
      a:hover {
        text-decoration: underline;
      }
"
  "*The CSS style used for hyperlinks when in CSS mode."
  :type 'string
  :group 'xhtmlize)

(defcustom xhtmlize-replace-form-feeds t
  "*Non-nil means replace form feeds in source code with HTML separators.
Form feeds are the ^L characters at line beginnings that are sometimes
used to separate sections of source code.  If this variable is set to
`t', form feed characters are replaced with the <hr> separator.  If this
is a string, it specifies the replacement to use.  Note that <pre> is
temporarily closed before the separator is inserted, so the default
replacement is effectively \"</pre><hr /><pre>\".  If you specify
another replacement, don't forget to close and reopen the <pre> if you
want the output to remain valid HTML.

If you need more elaborate processing, set this to nil and use
xhtmlize-after-hook."
  :type 'boolean
  :group 'xhtmlize)

(defcustom xhtmlize-html-charset nil
  "*The charset declared by the resulting HTML documents.
When non-nil, causes xhtmlize to insert the following in the HEAD section
of the generated HTML:

  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=CHARSET\">

where CHARSET is the value you've set for xhtmlize-html-charset.  Valid
charsets are defined by MIME and include strings like \"iso-8859-1\",
\"iso-8859-15\", \"utf-8\", etc.

If you are using non-Latin-1 charsets, you might need to set this for
your documents to render correctly.  Also, the W3C validator requires
submitted HTML documents to declare a charset.  So if you care about
validation, you can use this to prevent the validator from bitching.

Needless to say, if you set this, you should actually make sure that
the buffer is in the encoding you're claiming it is in.  (Under Mule
that is done by ensuring the correct \"file coding system\" for the
buffer.)  If you don't understand what that means, this option is
probably not for you."
  :type '(choice (const :tag "Unset" nil)
		 string)
  :group 'xhtmlize)

(defcustom xhtmlize-convert-nonascii-to-entities (featurep 'mule)
  "*Whether non-ASCII characters should be converted to HTML entities.

When this is non-nil, characters with codes in the 128-255 range will be
considered Latin 1 and rewritten as \"&#CODE;\".  Characters with codes
above 255 will be converted to \"&#UCS;\", where UCS denotes the Unicode
code point of the character.  If the code point cannot be determined,
the character will be copied unchanged, as would be the case if the
option were nil.

When the option is nil, the non-ASCII characters are copied to HTML
without modification.  In that case, the web server and/or the browser
must be set to understand the encoding that was used when saving the
buffer.  (You might also want to specify it by setting
`xhtmlize-html-charset'.)

Note that in an HTML entity \"&#CODE;\", CODE is always a UCS code point,
which has nothing to do with the charset the page is in.  For example,
\"&#169;\" *always* refers to the copyright symbol, regardless of charset
specified by the META tag or the charset sent by the HTTP server.  In
other words, \"&#169;\" is exactly equivalent to \"&copy;\".

By default, entity conversion is turned on for Mule-enabled Emacsen and
turned off otherwise.  This is because Mule knows the charset of
non-ASCII characters in the buffer.  A non-Mule Emacs cannot tell
whether a character with code 0xA9 represents Latin 1 copyright symbol,
Latin 2 \"S with caron\", or something else altogether.  Setting this to
t without Mule means asserting that 128-255 characters always mean Latin
1.

For most people xhtmlize will work fine with this option left at the
default setting; don't change it unless you know what you're doing."
  :type 'sexp
  :group 'xhtmlize)

(defcustom xhtmlize-ignore-face-size 'absolute
  "*Whether face size should be ignored when generating HTML.
If this is nil, face sizes are used.  If set to t, sizes are ignored
If set to `absolute', only absolute size specifications are ignored.
Please note that font sizes only work with CSS-based output types."
  :type '(choice (const :tag "Don't ignore" nil)
		 (const :tag "Ignore all" t)
		 (const :tag "Ignore absolute" absolute))
  :group 'xhtmlize)

(defcustom xhtmlize-css-name-prefix ""
  "*The prefix used for CSS names.
The CSS names that xhtmlize generates from face names are often too
generic for CSS files; for example, `font-lock-type-face' is transformed
to `type'.  Use this variable to add a prefix to the generated names.
The string \"xhtmlize-\" is an example of a reasonable prefix."
  :type 'string
  :group 'xhtmlize)

(defcustom xhtmlize-use-rgb-txt t
  "*Whether `rgb.txt' should be used to convert color names to RGB.

This conversion means determining, for instance, that the color
\"IndianRed\" corresponds to the (205, 92, 92) RGB triple.  `rgb.txt'
is the X color database that maps hundreds of color names to such RGB
triples.  When this variable is non-nil, `xhtmlize' uses `rgb.txt' to
look up color names.

If this variable is nil, xhtmlize queries Emacs for RGB components of
colors using `color-instance-rgb-components' and `x-color-values'.
This can yield incorrect results on non-true-color displays.

If the `rgb.txt' file is not found (which will be the case if you're
running Emacs on non-X11 systems), this option is ignored."
  :type 'boolean
  :group 'xhtmlize)

(defcustom xhtmlize-html-major-mode nil
  "The mode the newly created HTML buffer will be put in.
Set this to nil if you prefer the default (fundamental) mode."
  :type '(radio (const :tag "No mode (fundamental)" nil)
		 (function-item html-mode)
		 (function :tag "User-defined major mode"))
  :group 'xhtmlize)

(defcustom xhtmlize-external-css-base-url "file:///tmp"
  "*URL where css files are expected to be stored to."
  :type 'string
  :group 'xhtmlize)

(defcustom xhtmlize-external-css-base-dir "/tmp"
  "*Directory where css files are stored to."
  :type 'directory
  :group 'xhtmlize)

(defvar xhtmlize-builtin-faces nil)
(defun  xhtmlize-add-builtin-faces (face)
  (setq xhtmlize-builtin-faces 
	(adjoin face xhtmlize-builtin-faces :test 'equal)))

(defvar xhtmlize-before-hook nil
  "Hook run before htmlizing a buffer.
The hook functions are run in the source buffer (not the resulting HTML
buffer).")

(defvar xhtmlize-after-hook nil
  "Hook run after htmlizing a buffer.
Unlike `xhtmlize-before-hook', these functions are run in the generated
HTML buffer.  You may use them to modify the outlook of the final HTML
output.")

(defvar xhtmlize-file-hook nil
  "Hook run by `xhtmlize-file' after htmlizing a file, but before saving it.")

(defvar xhtmlize-buffer-places)

;;; Some cross-Emacs compatibility.

;(defun xhtmlize-fold (proc list result)
;  (if (null list)
;      result
;    (xhtmlize-fold proc (cdr list) 
;		  (funcall proc (car list) result))))

(defun xhtmlize-fold (proc list result)
  (while list
    (setq result (funcall proc (car list) result))
    (setq list (cdr list))
    )
  result)

(defun xhtmlize-overlays-at (p)
  (xhtmlize-overlays-between p
			     (let ((e0 (1+ p)))
			      (if (< (point-max) e0)
				  p
				e0))
			     t))

;; TODO: Merge following two functions.
;; xhtmlize-overlays-between and xhtmlize-next-change
(defun xhtmlize-overlays-between (p q require-sort-p)
  (let ((ovs (xhtmlize-fold (lambda (kar kdr)
			(if (xhtmlize-width0-overlay-acceptable-p kar)
			    (cons kar kdr)
			  kdr))
		(overlays-in p q)
		(list))))
    (if require-sort-p
	(sort ovs
	      (lambda (o0 o1)
		(< (overlay-start o0) (overlay-start o1))))
      (xhtmlize-fold (lambda (kar kdr)
		       (if (null kdr)
			   (cons kar nil)
			 (if (<= (overlay-start kar)
				 (overlay-start (car kdr)))
			     (cons kar nil)
			   kdr)))
		     ovs
		     nil))))

;; (defun xhtmlize-overlays-between (p q)
;;   (xhtmlize-fold (lambda (kar kdr)
;; 		   (if (xhtmlize-width0-overlay-acceptable-p kar)
;; 		       (cons kar kdr)
;; 		     kdr))
;; 		 (overlays-in p q)
;; 		 (list)))

(defun xhtmlize-next-change (pos prop &optional limit)
  ;; (message "<%d, %s>" pos limit) 
  (let ((r0 (next-char-property-change pos limit))
	(r1 (next-single-char-property-change pos prop nil limit))
	(r2 (next-single-property-change pos 'face nil limit)))
    (when (boundp 'engine)
      (unless r2
	(xhtmlize-engine-insert-comment engine (format "nil => %s" limit)))
      )
    (cond
     ;((eq r1 (point-max))
      ;;  (line-beginning-position 2)
      ;)
     ((< r0 r1)
      (let* ((ovs (xhtmlize-overlays-between r0 r1 nil))
	     (r00 (car ovs)))
	(or (and r00
		 (overlay-start r00))
	    r1)))
     (t
      r1))))
      
;;; Transformation of buffer text: HTML escapes, untabification, etc.

(defvar xhtmlize-basic-character-table
  ;; Map characters in the 0-127 range to either one-character strings
  ;; or to numeric entities.
  (let ((table (make-vector 128 ?\0)))
    ;; Map characters in the 32-126 range to themselves, others to
    ;; &#CODE entities;
    (dotimes (i 128)
      (setf (aref table i) (if (and (>= i 32) (<= i 126))
			       (char-to-string i)
			     (format "&#%d;" i))))
    ;; Set exceptions manually.
    (setf
     ;; Don't escape newline, carriage return, and TAB.
     (aref table ?\n) "\n"
     (aref table ?\r) "\r"
     (aref table ?\t) "\t"
     ;; Escape &, <, and >.
     (aref table ?&) "&amp;"
     (aref table ?<) "&lt;"
     (aref table ?>) "&gt;"
     ;; Not escaping '"' buys us a measurable speedup.  It's only
     ;; necessary to quote it for strings used in attribute values,
     ;; which xhtmlize doesn't do.
     ;(aref table ?\") "&quot;"
     )
    table))

;; A cache of HTML representation of non-ASCII characters.  Depending
;; on availability of `encode-char' and the setting of
;; `xhtmlize-convert-nonascii-to-entities', this maps non-ASCII
;; characters to either "&#<code>;" or "<char>" (mapconcat's mapper
;; must always return strings).  It's only filled as characters are
;; encountered, so that in a buffer with e.g. French text, it will
;; only ever contain French accented characters as keys.  It's cleared
;; on each entry to xhtmlize-buffer-1 to allow modifications of
;; `xhtmlize-convert-nonascii-to-entities' to take effect.
(defvar xhtmlize-extended-character-cache (make-hash-table :test 'eq))

(defun xhtmlize-protect-string (string)
  "HTML-protect string, escaping HTML metacharacters and I18N chars."
  ;; Only protecting strings that actually contain unsafe or non-ASCII
  ;; chars removes a lot of unnecessary funcalls and consing.
  (if (not (string-match "[^\r\n\t -%'-;=?-~]" string))
      string
    (mapconcat (lambda (char)
		 (cond
		  ((< char 128)
		   ;; ASCII: use xhtmlize-basic-character-table.
		   (aref xhtmlize-basic-character-table char))
		  ((gethash char xhtmlize-extended-character-cache)
		   ;; We've already seen this char; return the cached
		   ;; string.
		   )
		  ((not xhtmlize-convert-nonascii-to-entities)
		   ;; If conversion to entities is not desired, always
		   ;; copy the char literally.
		   (setf (gethash char xhtmlize-extended-character-cache)
			 (char-to-string char)))
		  ((< char 256)
		   ;; Latin 1: no need to call encode-char.
		   (setf (gethash char xhtmlize-extended-character-cache)
			 (format "&#%d;" char)))
		  ((and (fboundp 'encode-char)
			;; Must check if encode-char works for CHAR;
			;; it fails for Arabic and possibly elsewhere.
			(encode-char char 'ucs))
		   (setf (gethash char xhtmlize-extended-character-cache)
			 (format "&#%d;" (encode-char char 'ucs))))
		  (t
		   ;; encode-char doesn't work for this char.  Copy it
		   ;; unchanged and hope for the best.
		   (setf (gethash char xhtmlize-extended-character-cache)
			 (char-to-string char)))))
	       string "")))

(defconst xhtmlize-ellipsis "...")
(put-text-property 0 (length xhtmlize-ellipsis) 'xhtmlize-ellipsis t xhtmlize-ellipsis)

(defun xhtmlize-buffer-substring-no-invisible (beg end)
  ;; Like buffer-substring-no-properties, but don't copy invisible
  ;; parts of the region.  Where buffer-substring-no-properties
  ;; mandates an ellipsis to be shown, xhtmlize-ellipsis is inserted.
  (let ((pos beg)
	visible-list invisible show next-change)
    ;; Iterate over the changes in the `invisible' property and filter
    ;; out the portions where it's non-nil, i.e. where the text is
    ;; invisible.
    (while (< pos end)
      (setq invisible (get-char-property pos 'invisible)
	    next-change (xhtmlize-next-change pos 'invisible end))
      (if (not (listp buffer-invisibility-spec))
	  ;; If buffer-invisibility-spec is not a list, then all
	  ;; characters with non-nil `invisible' property are visible.
	  (setq show (not invisible))
	;; Otherwise, the value of a non-nil `invisible' property can be:
	;; 1. a symbol -- make the text invisible if it matches
	;;    buffer-invisibility-spec.
	;; 2. a list of symbols -- make the text invisible if
	;;    any symbol in the list matches
	;;    buffer-invisibility-spec.
	;; If the match of buffer-invisibility-spec has a non-nil
	;; CDR, replace the invisible text with an ellipsis.
	(let (match)
	  (if (symbolp invisible)
	      (setq match (member* invisible buffer-invisibility-spec
				   :key (lambda (i)
					  (if (symbolp i) i (car i)))))
	    (setq match (block nil
			  (dolist (elem invisible)
			    (let ((m (member*
				      elem buffer-invisibility-spec
				      :key (lambda (i)
					     (if (symbolp i) i (car i))))))
			      (when m (return m))))
			  nil)))
	  (setq show (cond ((null match) t)
			   ((and (cdr-safe (car match))
				 ;; Conflate successive ellipses.
				 (not (eq show xhtmlize-ellipsis)))
			    xhtmlize-ellipsis)
			   (t nil)))))
      (cond ((eq show t)
	     (push (buffer-substring-no-properties pos next-change) visible-list))
	    ((stringp show)
	     (push show visible-list)))
      (setq pos next-change))
    (if (= (length visible-list) 1)
	;; If VISIBLE-LIST consists of only one element, return it
	;; without concatenation.  This avoids additional consing in
	;; regions without any invisible text.
	(car visible-list)
      (apply #'concat (nreverse visible-list)))))

(defun xhtmlize-trim-ellipsis (text)
  ;; Remove xhtmlize-ellipses ("...") from the beginning of TEXT if it
  ;; starts with it.  It checks for the special property of the
  ;; ellipsis so it doesn't work on ordinary text that begins with
  ;; "...".
  (if (get-text-property 0 'xhtmlize-ellipsis text)
      (substring text (length xhtmlize-ellipsis))
    text))

(defconst xhtmlize-tab-spaces
  ;; A table of strings with spaces.  (aref xhtmlize-tab-spaces 5) is
  ;; like (make-string 5 ?\ ), except it doesn't cons.
  (let ((v (make-vector 32 nil)))
    (dotimes (i (length v))
      (setf (aref v i) (make-string i ?\ )))
    v))

(defun xhtmlize-untabify (text start-column)
  "Untabify TEXT, assuming it starts at START-COLUMN."
  (let ((column start-column)
	(last-match 0)
	(chunk-start 0)
	chunks match-pos tab-size)
    (while (string-match "[\t\n]" text last-match)
      (setq match-pos (match-beginning 0))
      (cond ((eq (aref text match-pos) ?\t)
	     ;; Encountered a tab: create a chunk of text followed by
	     ;; the expanded tab.
	     (push (substring text chunk-start match-pos) chunks)
	     ;; Increase COLUMN by the length of the text we've
	     ;; skipped since last tab or newline.  (Encountering
	     ;; newline resets it.)
	     (incf column (- match-pos last-match))
	     ;; Calculate tab size based on tab-width and COLUMN.
	     (setq tab-size (- tab-width (% column tab-width)))
	     ;; Expand the tab.
	     (push (aref xhtmlize-tab-spaces tab-size) chunks)
	     (incf column tab-size)
	     (setq chunk-start (1+ match-pos)))
	    (t
	     ;; Reset COLUMN at beginning of line.
	     (setq column 0)))
      (setq last-match (1+ match-pos)))
    ;; If no chunks have been allocated, it means there have been no
    ;; tabs to expand.  Return TEXT unmodified.
    (if (null chunks)
	text
      (when (< chunk-start (length text))
	;; Push the remaining chunk.
	(push (substring text chunk-start) chunks))
      ;; Generate the output from the available chunks.
      (apply #'concat (nreverse chunks)))))

(defun xhtmlize-despam-address (string)
  "Replace every occurrence of '@' in STRING with &#64;.
`xhtmlize-make-hyperlinks' uses this to spam-protect mailto links
without modifying their meaning."
  ;; Suggested by Ville Skytta.
  (while (string-match "@" string)
    (setq string (replace-match "&#64;" nil t string)))
  string)

(defun xhtmlize-make-hyperlinks ()
  "Make hyperlinks in HTML."
  ;; Function originally submitted by Ville Skytta.  Rewritten by
  ;; Hrvoje Niksic, then modified by Ville Skytta and Hrvoje Niksic.
  (goto-char (point-min))
  (while (re-search-forward
	  "&lt;\\(\\(mailto:\\)?\\([-=+_.a-zA-Z0-9]+@[-_.a-zA-Z0-9]+\\)\\)&gt;"
	  nil t)
    (let ((address (match-string 3))
	  (link-text (match-string 1)))
      (delete-region (match-beginning 0) (match-end 0))
      (insert "&lt;<a href=\"mailto:"
	      (xhtmlize-despam-address address)
	      "\">"
	      (xhtmlize-despam-address link-text)
	      "</a>&gt;")))
  (goto-char (point-min))
  (while (re-search-forward "&lt;\\(\\(URL:\\)?\\([a-zA-Z]+://[^;]+\\)\\)&gt;"
			    nil t)
    (let ((url (match-string 3))
	  (link-text (match-string 1)))
      (delete-region (match-beginning 0) (match-end 0))
      (insert "&lt;<a href=\"" url "\">" link-text "</a>&gt;"))))

;; Tests for xhtmlize-make-hyperlinks:

;; <mailto:hniksic@xemacs.org>
;; <http://fly.srk.fer.hr>
;; <URL:http://www.xemacs.org>
;; <http://www.mail-archive.com/bbdb-info@xemacs.org/>
;; <hniksic@xemacs.org>
;; <xalan-dev-sc.10148567319.hacuhiucknfgmpfnjcpg-john=doe.com@xml.apache.org>

(defun xhtmlize-defang-local-variables ()
  ;; Juri Linkov reports that an HTML-ized "Local variables" can lead
  ;; visiting the HTML to fail with "Local variables list is not
  ;; properly terminated".  He suggested changing the phrase to
  ;; syntactically equivalent HTML that Emacs doesn't recognize.
  (goto-char (point-min))
  (while (search-forward "Local Variables:" nil t)
    (replace-match "Local Variables&#58;" nil t)))
  

;;; Color handling.
(defmacro xhtmlize-copy-attr-if-set (attr-list dest source)
  ;; Expand the code of the type
  ;; (and (cssize-fstruct-ATTR source)
  ;;      (setf (cssize-fstruct-ATTR dest) (cssize-fstruct-ATTR source)))
  ;; for the given list of boolean attributes.
  (cons 'progn
	(loop for attr in attr-list
	      for attr-sym = (intern (format "cssize-fstruct-%s" attr))
	      collect `(and (,attr-sym ,source)
			    (setf (,attr-sym ,dest) (,attr-sym ,source))))))

(defun xhtmlize-merge-two-faces (merged next)
  (xhtmlize-copy-attr-if-set
   (foreground background boldp italicp underlinep overlinep strikep)
   merged next)
  (setf (cssize-fstruct-size merged)
	(cssize-merge-size (cssize-fstruct-size merged)
			    (cssize-fstruct-size next)))
  merged)

(defun xhtmlize-merge-faces (fstruct-list)
  (cond ((null fstruct-list)
	 ;; Nothing to do, return a dummy face.
	 (make-cssize-fstruct))
	((null (cdr fstruct-list))
	 ;; Optimize for the common case of a single face, simply
	 ;; return it.
	 (car fstruct-list))
	(t
	 (reduce #'xhtmlize-merge-two-faces
		 (cons (make-cssize-fstruct) fstruct-list)))))

;; GNU Emacs 20+ supports attribute lists in `face' properties.  For
;; example, you can use `(:foreground "red" :weight bold)' as an
;; overlay's "face", or you can even use a list of such lists, etc.
;; We call those "attrlists".
;;
;; xhtmlize supports attrlist by converting them to fstructs, the same
;; as with regular faces.

(defun xhtmlize-attrlist-to-fstruct (attrlist)
  ;; Like cssize-face-to-fstruct, but accepts an ATTRLIST as input.
  (let ((fstruct (make-cssize-fstruct)))
    (cond ((eq (car attrlist) 'foreground-color)
	   ;; ATTRLIST is (foreground-color . COLOR)
	   (setf (cssize-fstruct-foreground fstruct)
		 (cssize-color-to-rgb (cdr attrlist))))
	  ((eq (car attrlist) 'background-color)
	   ;; ATTRLIST is (background-color . COLOR)
	   (setf (cssize-fstruct-background fstruct)
		 (cssize-color-to-rgb (cdr attrlist))))
	  (t
	   ;; ATTRLIST is a plist.
	   (while attrlist
	     (let ((attr (pop attrlist))
		   (value (pop attrlist)))
	       (when (and value (not (eq value 'unspecified)))
		 (cssize-face-emacs21-attr fstruct attr value))))))
    (setf (cssize-fstruct-css-name fstruct) "ATTRLIST")
    fstruct))

(defun xhtmlize-face-list-p (face-prop)
  "Return non-nil if FACE-PROP is a list of faces, nil otherwise."
  ;; If not for attrlists, this would return (listp face-prop).  This
  ;; way we have to be more careful because attrlist is also a list!
  (cond
   ((eq face-prop nil)
    ;; FACE-PROP being nil means empty list (no face), so return t.
    t)
   ((symbolp face-prop)
    ;; A symbol other than nil means that it's only one face, so return
    ;; nil.
    nil)
   ((not (consp face-prop))
    ;; Huh?  Not a symbol or cons -- treat it as a single element.
    nil)
   (t
    ;; We know that FACE-PROP is a cons: check whether it looks like an
    ;; ATTRLIST.
    (let* ((car (car face-prop))
	   (attrlist-p (and (symbolp car)
			    (or (eq car 'foreground-color)
				(eq car 'background-color)
				(eq (aref (symbol-name car) 0) ?:)))))
      ;; If FACE-PROP is not an ATTRLIST, it means it's a list of
      ;; faces.
      (not attrlist-p)))))

(defun xhtmlize-make-face-map (engine faces)
  ;; Return a hash table mapping Emacs faces to xhtmlize's fstructs.
  ;; The keys are either face symbols or attrlists, so the test
  ;; function must be `equal'.
  (let ((face-map (make-hash-table :test 'equal))
	css-names)
    (dolist (face faces)
      (unless (gethash face face-map)
	;; Haven't seen FACE yet; convert it to an fstruct and cache
	;; it.
	(let ((fstruct (if (symbolp face)
			   (cssize-face-to-fstruct face)
			 (xhtmlize-attrlist-to-fstruct face))))
	  (setf (gethash face face-map) fstruct)
	  (let* ((css-name (cssize-fstruct-css-name fstruct))
		 (new-name css-name)
		 (i 0))
	    ;; Uniquify the face's css-name by using NAME-1, NAME-2,
	    ;; etc.
	    (while (member new-name css-names)
	      (setq new-name (format "%s-%s" css-name (incf i))))
	    (unless (equal new-name css-name)
	      (setf (cssize-fstruct-css-name fstruct) new-name))
	    (push new-name css-names)))))
    face-map))

(defun xhtmlize-unstringify-face (face)
  "If FACE is a string, return it interned, otherwise return it unchanged."
  (if (stringp face)
      (intern face)
    face))

(defun xhtmlize-record-first-single-property-change (engine fmt)
  (xhtmlize-engine-insert-comment engine
				  (format fmt
					  (next-single-property-change (point-min)
								       'face))))

(defun xhtmlize-faces-in-buffer (engine)
  "Return a list of faces used in the current buffer.
Under
GNU Emacs, it returns the set of faces specified by the `face' text
property and by buffer overlays that specify `face'."
  (let (faces)
    ;; FSF Emacs code.
    ;; Faces used by text properties.
    (let ((pos (point-min)) face-prop next)
      (while (< pos (point-max))
	(setq face-prop (get-text-property pos 'face)
	      next (or (next-single-property-change pos 'face) 
		       (point-max)))
	;; FACE-PROP can be a face/attrlist or a list thereof.
	(setq faces (if (xhtmlize-face-list-p face-prop)
			(nunion (mapcar #'xhtmlize-unstringify-face face-prop)
				faces :test 'equal)
		      (adjoin (xhtmlize-unstringify-face face-prop)
			      faces :test 'equal)))
	(setq pos next)))
    ;; Faces used by overlays.
    (dolist (overlay (overlays-in (point-min) (point-max)))
      (let ((face-prop (overlay-get overlay 'face)))
	;; FACE-PROP can be a face/attrlist or a list thereof.
	(setq faces (if (xhtmlize-face-list-p face-prop)
			(nunion (mapcar #'xhtmlize-unstringify-face face-prop)
				faces :test 'equal)
		      (adjoin (xhtmlize-unstringify-face face-prop)
			      faces :test 'equal)))))
    faces))

;; xhtmlize-faces-at-point returns the faces in use at point.  The
;; faces are sorted by increasing priority, i.e. the last face takes
;; precedence.
;;
;; Under GNU Emacs, this returns all the faces in the `face'
;; property and all the faces in the overlays at point.

(defun xhtmlize-faces-at-point ()
  (let (all-faces)
    ;; Faces from text properties.
    (let ((face-prop (get-text-property (point) 'face)))
      (setq all-faces (if (xhtmlize-face-list-p face-prop)
			  (nreverse (mapcar #'xhtmlize-unstringify-face
					    face-prop))
			(list (xhtmlize-unstringify-face face-prop)))))
    ;; Faces from overlays.
    (let ((overlays
	   ;; Collect overlays at point that specify `face'.
	   (delete-if-not (lambda (o)
			    (overlay-get o 'face))
			  (overlays-at (point))))
	  list face-prop)
      ;; Sort the overlays so the smaller (more specific) ones
      ;; come later.  The number of overlays at each one
      ;; position should be very small, so the sort shouldn't
      ;; slow things down.
      (setq overlays (sort* overlays
			    ;; Sort by ascending...
			    #'<
			    ;; ...overlay size.
			    :key (lambda (o)
				   (- (overlay-end o)
				      (overlay-start o)))))
      ;; Overlay priorities, if present, override the above
      ;; established order.  Larger overlay priority takes
      ;; precedence and therefore comes later in the list.
      (setq overlays (stable-sort
		      overlays
		      ;; Reorder (stably) by acending...
		      #'<
		      ;; ...overlay priority.
		      :key (lambda (o)
			     (or (overlay-get o 'priority) 0))))
      (dolist (overlay overlays)
	(setq face-prop (overlay-get overlay 'face))
	(setq list (if (xhtmlize-face-list-p face-prop)
		       (nconc (nreverse (mapcar
					 #'xhtmlize-unstringify-face
					 face-prop))
			      list)
		     (cons (xhtmlize-unstringify-face face-prop) list))))
      ;; Under "Merging Faces" the manual explicitly states
      ;; that faces specified by overlays take precedence over
      ;; faces specified by text properties.
      (setq all-faces (nconc all-faces list)))
    all-faces))

;; xhtmlize supports generating HTML in two several fundamentally
;; different ways, one with the use of CSS and nested <span> tags, and
;; the other with the use of the old <font> tags.  Rather than adding
;; a bunch of ifs to many places, we take a semi-OO approach.
;; `xhtmlize-buffer-1' calls a number of "methods", which indirect to
;; the functions that depend on `xhtmlize-output-type'.  The currently
;; used methods are `doctype', `insert-head', `body-tag', and
;; `insert-text-with-id'.  Not all output types define all methods.
;;
;; Methods are called either with (xhtmlize-method METHOD ARGS...) 
;; special form, or by accessing the function with
;; (xhtmlize-method-function 'METHOD) and calling (funcall FUNCTION).
;; The latter form is useful in tight loops because `xhtmlize-method'
;; conses.
;;
;; Currently defined output types are `css' and `font'.

(defmacro xhtmlize-method (method &rest args)
  ;; Expand to (xhtmlize-TYPE-METHOD ...ARGS...).  TYPE is the value of
  ;; `xhtmlize-output-type' at run time.
  `(funcall (xhtmlize-method-function ',method) ,@args))

(defun xhtmlize-method-function (method)
  ;; Return METHOD's function definition for the current output type.
  ;; The returned object can be safely funcalled.
  (let ((sym (intern (format "xhtmlize-%s-%s" xhtmlize-output-type method))))
    (indirect-function (if (fboundp sym)
			   sym
			 (let ((default (intern (concat "xhtmlize-default-"
							(symbol-name method)))))
			   (if (fboundp default)
			       default
			     'ignore))))))

(defvar xhtmlize-memoization-table (make-hash-table :test 'equal))

(defmacro xhtmlize-memoize (key generator)
  "Return the value of GENERATOR, memoized as KEY.
That means that GENERATOR will be evaluated and returned the first time
it's called with the same value of KEY.  All other times, the cached
\(memoized) value will be returned."
  (let ((value (gensym)))
    `(let ((,value (gethash ,key xhtmlize-memoization-table)))
       (unless ,value
	 (setq ,value ,generator)
	 (setf (gethash ,key xhtmlize-memoization-table) ,value))
       ,value)))

;;; Default methods.

(defun xhtmlize-default-doctype ()
  nil					; no doc-string
  ;; According to DTDs published by the W3C, it is illegal to embed
  ;; <font> in <pre>.  This makes sense in general, but is bad for
  ;; xhtmlize's intended usage of <font> to specify the document color.

  ;; To make generated HTML legal, xhtmlize's `font' mode used to
  ;; specify the SGML declaration of "HTML Pro" DTD here.  HTML Pro
  ;; aka Silmaril DTD was a project whose goal was to produce a GPL'ed
  ;; DTD that would encompass all the incompatible HTML extensions
  ;; procured by Netscape, MSIE, and other players in the field.
  ;; Apparently the project got abandoned, the last available version
  ;; being "Draft 0 Revision 11" from January 1997, as documented at
  ;; <http://imbolc.ucc.ie/~pflynn/articles/htmlpro.html>.

  ;; Since by now HTML Pro is remembered by none but the most die-hard
  ;; early-web-days nostalgics and used by not even them, there is no
  ;; use in specifying it.  So we return the standard HTML 4.0
  ;; declaration, which makes generated HTML technically illegal.  If
  ;; you have a problem with that, use the `css' engine designed to
  ;; create fully conforming HTML.

  ;; HTMLIZE:
  ;;"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\">"
  ;; XHTMLIZE:
  (concat "<!DOCTYPE html\n    PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n"
	  "    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">")
  ;; Now-abandoned HTML Pro declaration.
  ;"<!DOCTYPE HTML PUBLIC \"+//Silmaril//DTD HTML Pro v0r11 19970101//EN\">"
  )

(defun xhtmlize-default-body-tag (face-map)
  nil					; no doc-string
  "<body>")

;;; External CSS based output support.
;; Return nil if css files exist.
(defun xhtmlize-css-link (face css-dir insert-func)
  (let ((default 
	  (xhtmlize-css-link0 face css-dir "black" "white" "Default" insert-func))
	(invert
	 (xhtmlize-css-link0 face css-dir "white" "black" "Invert" insert-func)) )
    (or default invert)))

(defun xhtmlize-css-link0 (face css-dir fg bg title insert-func)
  (prog1
      (if (xhtmlize-css-cached-on-disk-p face css-dir title)
	  nil
	(set-foreground-color fg)
	(set-background-color bg)
	(xhtmlize-css-make-cache-on-disk face css-dir title)))
  (funcall insert-func face title))

(defun xhtmlize-css-link-insert (face title)
  (insert "    <link rel=\"stylesheet\" type=\"text/css\""
	  (format " href=\"%s/%s\""
		  xhtmlize-external-css-base-url
		  (xhtmlize-css-make-file-name face title)
		  )
	  (format " title=\"%s\"" title)
	  "/>"
	  ?\n))

(defun xhtmlize-external-css-enumerate-faces (buffer-faces face-map)
  (cons
   'default
   (append
    xhtmlize-builtin-faces
    (sort* (copy-list buffer-faces) #'string-lessp
	   :key (lambda (f)
		  (cssize-fstruct-css-name (gethash f face-map)))))))

(defun xhtmlize-external-css-insert-head (buffer-faces face-map)
  (let ((wrote-css-p nil))
    (dolist (face (xhtmlize-external-css-enumerate-faces buffer-faces face-map))
      (when (xhtmlize-css-link face 
			       xhtmlize-external-css-base-dir
			       #'xhtmlize-css-link-insert)
	(setq wrote-css-p t)))
    wrote-css-p))

(defun xhtmlize-css-make-file-name (face title)
  (concat (cssize-clean-up-face-name face) "--" title "." "css"))

(defun xhtmlize-css-cached-on-disk-p (face dir title)
  (let ((file (xhtmlize-css-make-file-name face title)))
    (let ((path (concat (file-name-as-directory dir) file)))
      (file-readable-p path))))

(defun xhtmlize-css-make-cache-on-disk (face dir title)
  (unless (xhtmlize-css-cached-on-disk-p face dir title)
    (xhtmlize-css-make-cache-on-disk0 face dir title)))

(defun xhtmlize-cssize (face dir title)
  (xhtmlize-css-make-cache-on-disk0 face dir title))

(defun xhtmlize-css-make-cache-on-disk0 (face dir title)
  (let ((file (xhtmlize-css-make-file-name face title)))
    (let ((path (concat (file-name-as-directory dir) file)))
      (cssize-file face path))))

(defun xhtmlize-external-css-insert-text-with-id (text id href fstruct-list engine)
  (xhtmlize-css-insert-text-with-id text id href fstruct-list engine)
  )


;;; CSS based output support.

;; Internal function; not a method.
(defun xhtmlize-css-specs (fstruct)
  (let (result)
    (when (cssize-fstruct-foreground fstruct)
      (push (format "color: %s;" (cssize-fstruct-foreground fstruct))
	    result))
    (when (cssize-fstruct-background fstruct)
      (push (format "background-color: %s;"
		    (cssize-fstruct-background fstruct))
	    result))
    (let ((size (cssize-fstruct-size fstruct)))
      (when (and size (not (eq xhtmlize-ignore-face-size t)))
	(cond ((floatp size)
	       (push (format "font-size: %d%%;" (* 100 size)) result))
	      ((not (eq xhtmlize-ignore-face-size 'absolute))
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
    (nreverse result)))

(defun xhtmlize-css-insert-head (buffer-faces face-map)
  (insert "    <style type=\"text/css\">\n    <!--\n")
  (insert "      body {\n        "
	  (mapconcat #'identity
		     (xhtmlize-css-specs (gethash 'default face-map))
		     "\n        ")
	  "\n      }\n")
  (dolist (face (sort* (copy-list (nunion xhtmlize-builtin-faces 
					  buffer-faces :test 'equal))
		       #'string-lessp
		       :key (lambda (f)
			      (cssize-fstruct-css-name (gethash f face-map)))))
    (let* ((fstruct (gethash face face-map))
	   (cleaned-up-face-name
	    (let ((s
		   ;; Use `prin1-to-string' rather than `symbol-name'
		   ;; to get the face name because the "face" can also
		   ;; be an attrlist, which is not a symbol.
		   (prin1-to-string face)))
	      ;; If the name contains `--' or `*/', remove them.
	      (while (string-match "--" s)
		(setq s (replace-match "-" t t s)))
	      (while (string-match "\\*/" s)
		(setq s (replace-match "XX" t t s)))
	      s))
	   (specs (xhtmlize-css-specs fstruct)))
      (insert "      ." (cssize-fstruct-css-name fstruct))
      (if (null specs)
	  (insert " {")
	(insert " {\n        /* " cleaned-up-face-name " */\n        "
		(mapconcat #'identity specs "\n        ")))
      (insert "\n      }\n")))
  (insert xhtmlize-hyperlink-style
	  "    -->\n    </style>\n")
  nil)


(defmacro with-xhtmlize-engine-canvas (name engine &rest body)
  `(let ((,name (oref ,engine canvas)))
	      ,@body))

(put 'with-xhtmlize-engine-canvas 'lisp-indent-function 2)

(defun xhtmlize-css-insert-text-with-id (text id href fstruct-list engine)
  ;; Insert TEXT colored with FACES into BUFFER.  In CSS mode, this is
  ;; easy: just nest the text in one <span class=...> tag for each
  ;; face in FSTRUCT-LIST.
  ;;
  (with-xhtmlize-engine-canvas buffer engine
    (dolist (fstruct fstruct-list)
      (princ "<span class=\"" buffer)
      (princ (cssize-fstruct-css-name fstruct) buffer)
      (when id
	(princ "\" id=\"" buffer)
	;; TODO HTML ESCAPING
	(princ id buffer)
	)
      (princ "\">" buffer))

    (when href
      (princ "<a href=\"" buffer)
      (princ (xhtmlize-protect-string href) buffer)
      (princ "\">" buffer))

    (princ (xhtmlize-protect-string text) buffer)

    (when href
      (princ "</a>" buffer)
      )
    
    (dolist (fstruct fstruct-list)
      (ignore fstruct)			; shut up the byte-compiler
      (princ "</span>" buffer))
    ))



;; `inline-css' output support.

(defun xhtmlize-inline-css-body-tag (face-map)
  (format "<body style=\"%s\">"
	  (mapconcat #'identity (xhtmlize-css-specs (gethash 'default face-map))
		     " ")))

(defun xhtmlize-inline-css-insert-text-with-id (text id href fstruct-list engine)
  (with-xhtmlize-engine-canvas buffer engine
    (let* ((merged (xhtmlize-merge-faces fstruct-list))
	   (style (xhtmlize-memoize
		   merged
		   (let ((specs (xhtmlize-css-specs merged)))
		     (and specs
			  (mapconcat #'identity (xhtmlize-css-specs merged) " "))))))
      (when style
	(princ "<span style=\"" buffer)
	(princ style buffer)
	(princ "\">" buffer))
      (princ (xhtmlize-protect-string text) buffer)
      (when style
	(princ "</span>" buffer)))))


;;; `font' tag based output support.

(defun xhtmlize-font-body-tag (face-map)
  (let ((fstruct (gethash 'default face-map)))
    (format "<body text=\"%s\" bgcolor=\"%s\">"
	    (cssize-fstruct-foreground fstruct)
	    (cssize-fstruct-background fstruct))))
       
(defun xhtmlize-font-insert-text-with-id (text id href fstruct-list engine)
  (with-xhtmlize-engine-canvas buffer engine
    ;; In `font' mode, we use the traditional HTML means of altering
    ;; presentation: <font> tag for colors, <b> for bold, <u> for
    ;; underline, and <strike> for strike-through.
    (let* ((merged (xhtmlize-merge-faces fstruct-list))
	   (markup (xhtmlize-memoize
		    merged
		    (cons (concat
			   (and (cssize-fstruct-foreground merged)
				(format "<font color=\"%s\">" (cssize-fstruct-foreground merged)))
			   (and (cssize-fstruct-boldp merged)      "<b>")
			   (and (cssize-fstruct-italicp merged)    "<i>")
			   (and (cssize-fstruct-underlinep merged) "<u>")
			   (and (cssize-fstruct-strikep merged)    "<strike>"))
			  (concat
			   (and (cssize-fstruct-strikep merged)    "</strike>")
			   (and (cssize-fstruct-underlinep merged) "</u>")
			   (and (cssize-fstruct-italicp merged)    "</i>")
			   (and (cssize-fstruct-boldp merged)      "</b>")
			   (and (cssize-fstruct-foreground merged) "</font>"))))))
      (princ (car markup) buffer)
      (princ (xhtmlize-protect-string text) buffer)
      (princ (cdr markup) buffer))))


(defvar xhtmlize-width0-overlay-handlers (list))

(defun define-xhtmlize-width0-overlay-handler (acceptable-p
					       render-direct
					       prepare
					       make-id
					       make-href)
  (setq xhtmlize-width0-overlay-handlers
	(cons `((acceptable-p  . ,acceptable-p  )
		(render-direct . ,render-direct )
		(prepare       . ,prepare       )
		(make-id       . ,make-id       )
		(make-href     . ,make-href     ))
	      xhtmlize-width0-overlay-handlers)))

(defun xhtmlize-width0-overlay-acceptable-p (o)
  (let ((handlers xhtmlize-width0-overlay-handlers ))
    (xhtmlize-width0-overlay-acceptable-p0 o handlers)))
(defun xhtmlize-width0-overlay-acceptable-p0 (o handlers)
  (if (null handlers)
      nil
    (let ((handler (assq 'acceptable-p (car handlers))))
      (if handler
	  (let ((r (funcall (cdr handler) o)))
	    (if r
		(car handlers)
	      (xhtmlize-width0-overlay-acceptable-p0 o (cdr handlers))))
	;; ???
	(xhtmlize-width0-overlay-acceptable-p0 o (cdr handlers))
	))))

(defun xhtmlize-width0-overlay-render-direct (o handler insert-method face-map htmlbuf)
  (let ((func (cdr (assq 'render-direct handler))))
    (if func
	(prog1 t
	  (funcall func o insert-method face-map htmlbuf)
	  )
      nil)))

(defun xhtmlize-width0-overlay-prepare (o handler)
  (funcall (cdr (assq 'prepare handler)) o))
(defun xhtmlize-width0-overlay-make-id (o handler)
  (funcall (cdr (assq 'make-id handler)) o))
(defun xhtmlize-width0-overlay-make-href (o handler)
  (let ((f (cdr (assq 'make-href handler))))
    (if f
	(funcall f o)
      nil)))

(defvar xhtmlize-width0-overlay-temp-buffer (let ((b (get-buffer-create
							  " *width0-overlay-xhtmlize*")))
						  (with-current-buffer b
						    (buffer-disable-undo))
						  b))

(defun xhtmlize-width0-overlay (o insert-method face-map engine)
  (let ((handler (xhtmlize-width0-overlay-acceptable-p o)))
    (when handler
      ;;
      (unless (xhtmlize-width0-overlay-render-direct o
						     handler
						     insert-method
						     face-map
						     engine)
	(let ((s (xhtmlize-width0-overlay-prepare o handler)))
	  ;; TODO: Don't use `with-current-buffer'.
	  (with-current-buffer xhtmlize-width0-overlay-temp-buffer
	    (erase-buffer) 
	    (when s (insert s))
	    (xhtmlize-buffer-0 o handler insert-method face-map engine))))
      ;;
      )))

(defun xhtmlize-buffer-0 (o handler insert-method face-map engine)
  (with-xhtmlize-engine-canvas htmlbuf engine
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
	(when (> (length text) 0)
	  ;; Insert the text, along with the necessary markup to
	  ;; represent faces in FSTRUCT-LIST.
	  (funcall insert-method
		   text
		   (xhtmlize-width0-overlay-make-id o handler)
		   (xhtmlize-width0-overlay-make-href o handler)
		   fstruct-list htmlbuf))
	(goto-char next-change))
      )))

;;
;; Engine stub
;;
(defvar xhtmlize-engine-alist (list))
(defun define-xhtmlize-engine (name class)
  (setq xhtmlize-engine-alist
	(cons `(,name . ,class)
	      xhtmlize-engine-alist)))
(defun xhtmlize-engine-for (name)
  (let ((engine-class (cdr (assq name xhtmlize-engine-alist))))
    (if engine-class
	(funcall engine-class (symbol-name name))
      nil)))
  
(defclass <xhtmlize-common-engine> ()
  ((canvas :initform nil)
   ;; Having a dummy value in the plist allows writing simply
   ;; (plist-put places foo bar).
   (places :initform (nil nil))
   (buffer-faces :initform nil)
   (face-map :initform nil)
   (prepared-p :initform nil)
   (early-comments :initform nil)
   (wrote-css-p :initform nil)
   ))

(defmethod xhtmlize-engine-prepare ((engine <xhtmlize-common-engine>))
  (oset engine
	buffer-faces (xhtmlize-faces-in-buffer engine))
  (oset engine
	face-map (xhtmlize-make-face-map
		  engine
		  (nunion (cons 'default xhtmlize-builtin-faces)
			  (oref engine buffer-faces) :test 'equal))))
(defmethod xhtmlize-engine-prologue ((engine <xhtmlize-common-engine>) title)
  )
(defmethod xhtmlize-engine-body ((engine <xhtmlize-common-engine>))
  )

(defmethod xhtmlize-engine-body-common ((engine <xhtmlize-common-engine>)
					insert-text-with-id-method)
  (with-slots (face-map) engine
    (let (;; Declare variables used in loop body outside the loop
	  ;; because it's faster to establish `let' bindings only
	  ;; once.
	  ;; (linum-mode-p (and (boundp 'linum-mode) linum-mode))
	  next-change text len face-list fstruct-list trailing-ellipsis pnt)
      ;; This loop traverses and reads the source buffer, appending
      ;; the resulting HTML to HTMLBUF with `princ'.  This method is
      ;; fast because: 1) it doesn't require examining the text
      ;; properties char by char (xhtmlize-next-change is used to
      ;; move between runs with the same face), and 2) it doesn't
      ;; require buffer switches, which are slow in Emacs.
      (goto-char (point-min))
      (while (not (eobp))
	(setq pnt (point))
	(mapc (lambda (o)
		(xhtmlize-width0-overlay o 
					 insert-text-with-id-method
					 face-map
					 engine)
		)
	      (xhtmlize-overlays-at (point)))
	
	(setq next-change (xhtmlize-next-change pnt 'face))
	(cond
	 ((not (numberp next-change))
	  (log+error "ERROR: %s is not number" next-change))
	 ((< next-change pnt)
	  (log+error "ERROR<0>: next-change:%d < (point:%d)" next-change pnt))
	 )
	;; Get faces in use between (point) and NEXT-CHANGE, and
	;; convert them to fstructs.
	(setq face-list (xhtmlize-faces-at-point)
	      fstruct-list (delq nil (mapcar (lambda (f)
					       (gethash f face-map))
					     face-list)))
	;; Extract buffer text, sans the invisible parts.  Then
	;; untabify it and escape the HTML metacharacters.
	(setq text (xhtmlize-buffer-substring-no-invisible pnt next-change)
	      len  (length text))
	(when trailing-ellipsis
	  (setq text (xhtmlize-trim-ellipsis text)
		len (length text)))
	;; If TEXT ends up empty, don't change trailing-ellipsis.
	(when (> len 0)
	  (setq trailing-ellipsis
		(get-text-property (1- len)
				   'xhtmlize-ellipsis text)))
	(setq text (xhtmlize-untabify text (current-column))
	      len  (length text))
	;; Don't bother writing anything if there's no text (this
	;; happens in invisible regions).
	(when (> len 0)
	  ;; Insert the text, along with the necessary markup to
	  ;; represent faces in FSTRUCT-LIST.
	  (funcall insert-text-with-id-method text 
					;(format "font-lock:%s" (point))
		   (concat "P:" (number-to-string pnt))
		   nil
		   fstruct-list
		   engine))
	(cond
	 ((< next-change pnt)
	  (log+error "ERROR<1>: next-change:%d < (point:%d)" next-change pnt)))
	(goto-char next-change)))))

(defmethod xhtmlize-engine-epilogue ((engine <xhtmlize-common-engine>))
  )
(defmethod xhtmlize-engine-process ((engine <xhtmlize-common-engine>))
  )

(defmethod xhtmlize-engine-make-file-name ((engine <xhtmlize-common-engine>) file)
  )

(defmethod xhtmlize-engine-insert-comment ((engine <xhtmlize-common-engine>) comment)
  (unless (oref engine prepared-p)
    (oset engine
	  early-comments (cons comment (oref engine early-comments)))))

(defun xhtmlize-buffer-1 (&optional engine)
  (unless engine
    (setq engine (xhtmlize-engine-for nil)))
  ;; Internal function; don't call it from outside this file.  Xhtmlize
  ;; current buffer, writing the resulting HTML to a new buffer, and
  ;; return it.  Unlike xhtmlize-buffer, this doesn't change current
  ;; buffer or use switch-to-buffer.
  (save-excursion
    ;; Protect against the hook changing the current buffer.
    (save-excursion
      (run-hooks 'xhtmlize-before-hook))
    ;; Convince font-lock support modes to fontify the entire buffer
    ;; in advance.
    (xhtmlize-ensure-fontified)
    (clrhash xhtmlize-extended-character-cache)
    (clrhash xhtmlize-memoization-table)
    ;;
    (xhtmlize-engine-prepare engine)
    (xhtmlize-engine-prologue engine (if (buffer-file-name)
					 (file-name-nondirectory (buffer-file-name))
				       (buffer-name)))
    ;;
    (when (oref engine wrote-css-p)
      (log-string "refontification...")
      (font-lock-fontify-buffer)
      (log-string "refontification...done"))
    ;;
    (xhtmlize-engine-body engine)
    (xhtmlize-engine-epilogue engine)
    (xhtmlize-engine-process engine)
    ))

;; Utility functions.

(defmacro xhtmlize-with-fontify-message (&rest body)
  ;; When forcing fontification of large buffers in
  ;; xhtmlize-ensure-fontified, inform the user that he is waiting for
  ;; font-lock, not for xhtmlize to finish.
  `(progn
     (if (> (buffer-size) 65536)
	 (message "Forcing fontification of %s..."
		  (buffer-name (current-buffer))))
     ,@body
     (if (> (buffer-size) 65536)
	 (message "Forcing fontification of %s...done"
		  (buffer-name (current-buffer))))))

(defun xhtmlize-ensure-fontified ()
  ;; If font-lock is being used, ensure that the "support" modes
  ;; actually fontify the buffer.  If font-lock is not in use, we
  ;; don't care because, except in xhtmlize-file, we don't force
  ;; font-lock on the user.
  (when (and (boundp 'font-lock-mode)
	     font-lock-mode)
    ;; In part taken from ps-print-ensure-fontified in GNU Emacs 21.
    (cond
     ((and (boundp 'jit-lock-mode)
	   (symbol-value 'jit-lock-mode))
      (xhtmlize-with-fontify-message
       (jit-lock-fontify-now (point-min) (point-max))))
     ((and (boundp 'lazy-lock-mode)
	   (symbol-value 'lazy-lock-mode))
      (xhtmlize-with-fontify-message
       (lazy-lock-fontify-region (point-min) (point-max))))
     ((and (boundp 'lazy-shot-mode)
	   (symbol-value 'lazy-shot-mode))
      (xhtmlize-with-fontify-message
       ;; lazy-shot is amazing in that it must *refontify* the region,
       ;; even if the whole buffer has already been fontified.  <sigh>
       (lazy-shot-fontify-region (point-min) (point-max))))
     ;; There's also fast-lock, but we don't need to handle specially,
     ;; I think.  fast-lock doesn't really defer fontification, it
     ;; just saves it to an external cache so it's not done twice.
     )))


;;;###autoload
(defun xhtmlize-buffer (&optional buffer engine-name)
  "Convert BUFFER to HTML, preserving colors and decorations.

The generated HTML is available in a new buffer, which is returned.
When invoked interactively, the new buffer is selected in the current
window.  The title of the generated document will be set to the buffer's
file name or, if that's not available, to the buffer's name.

Note that xhtmlize doesn't fontify your buffers, it only uses the
decorations that are already present.  If you don't set up font-lock or
something else to fontify your buffers, the resulting HTML will be
plain.  Likewise, if you don't like the choice of colors, fix the mode
that created them, or simply alter the faces it uses."
  (interactive)
  (let ((htmlbuf (with-current-buffer (or buffer (current-buffer))
		   (xhtmlize-buffer-1 (xhtmlize-engine-for engine-name)))))
    (when (interactive-p)
      (switch-to-buffer htmlbuf))
    htmlbuf))

;;;###autoload
(defun xhtmlize-region (beg end)
  "Convert the region to HTML, preserving colors and decorations.
See `xhtmlize-buffer' for details."
  (interactive "r")
  ;; Don't let zmacs region highlighting end up in HTML.
  (when (fboundp 'zmacs-deactivate-region)
    (zmacs-deactivate-region))
  (let ((htmlbuf (save-restriction
		   (narrow-to-region beg end)
		   (xhtmlize-buffer-1))))
    (when (interactive-p)
      (switch-to-buffer htmlbuf))
    htmlbuf))

(defun xhtmlize-region-for-paste (beg end)
  "Xhtmlize the region and return just the HTML as a string.
This forces the `inline-css' style and only returns the HTML body,
but without the BODY tag.  This should make it useful for inserting
the text to another HTML buffer."
  (let* ((xhtmlize-output-type 'inline-css)
	 (htmlbuf (xhtmlize-region beg end)))
    (unwind-protect
	(with-current-buffer htmlbuf
	  (buffer-substring (plist-get xhtmlize-buffer-places 'content-start)
			    (plist-get xhtmlize-buffer-places 'content-end)))
      (kill-buffer htmlbuf))))

;;;###autoload
(defun xhtmlize-file (file &optional target engine-name)
  "Load FILE, fontify it, convert it to HTML, and save the result.

Contents of FILE are inserted into a temporary buffer, whose major mode
is set with `normal-mode' as appropriate for the file type.  The buffer
is subsequently fontified with `font-lock' and converted to HTML.  Note
that, unlike `xhtmlize-buffer', this function explicitly turns on
font-lock.  If a form of highlighting other than font-lock is desired,
please use `xhtmlize-buffer' directly on buffers so highlighted.

Buffers currently visiting FILE are unaffected by this function.  The
function does not change current buffer or move the point.

If TARGET is specified and names a directory, the resulting file will be
saved there instead of to FILE's directory.  If TARGET is specified and
does not name a directory, it will be used as output file name."
  (interactive (list (read-file-name
		      "HTML-ize file: "
		      nil nil nil (and (buffer-file-name)
				       (file-name-nondirectory
					(buffer-file-name))))))
  (let* ((engine (xhtmlize-engine-for engine-name))
	 (output-file (if (and target (not (file-directory-p target)))
			  target
			(expand-file-name
			 (xhtmlize-engine-make-file-name engine (file-name-nondirectory file))
			 (or target (file-name-directory file)))))
	 ;; Try to prevent `find-file-noselect' from triggering
	 ;; font-lock because we'll fontify explicitly below.
	 (font-lock-mode nil)
	 (font-lock-auto-fontify nil)
	 (global-font-lock-mode nil)
	 ;; Ignore the size limit for the purposes of htmlization.
	 (font-lock-maximum-size nil)
	 ;; Disable font-lock support modes.  This will only work in
	 ;; more recent Emacs versions, so xhtmlize-buffer-1 still needs
	 ;; to call xhtmlize-ensure-fontified.
	 (font-lock-support-mode nil))
    (with-temp-buffer
      ;; Insert FILE into the temporary buffer.
      (if (file-directory-p file)
	  ;; NEW CODE: Use dired.
	  (insert (save-excursion
		    (let* ((b (dired file)))
		      (prog1 (buffer-string)
			(setq file (directory-file-name file))
			(kill-buffer b)))))
	(insert-file-contents file))
      ;; Set the file name so normal-mode and xhtmlize-buffer-1 pick it
      ;; up.  Restore it afterwards so with-temp-buffer's kill-buffer
      ;; doesn't complain about killing a modified buffer.
      (let ((buffer-file-name file)
	    (noninteractive nil))
	;; Set the major mode for the sake of font-lock.
	(normal-mode)
	(font-lock-mode 1)
	(unless font-lock-mode
	  ;; In GNU Emacs (font-lock-mode 1) doesn't force font-lock,
	  ;; contrary to the documentation.  This seems to work.
	  (font-lock-fontify-buffer))
	;; xhtmlize the buffer and save the HTML.
	(with-current-buffer (xhtmlize-buffer-1 engine)
	  (unwind-protect
	      (progn
		(run-hooks 'xhtmlize-file-hook)
		(write-region (point-min) (point-max) output-file))
	    (kill-buffer (current-buffer)))))))
  ;; I haven't decided on a useful return value yet, so just return
  ;; nil.
  nil)

;;;###autoload
(defun xhtmlize-many-files (files &optional target-directory)
  "Convert FILES to HTML and save the corresponding HTML versions.

FILES should be a list of file names to convert.  This function calls
`xhtmlize-file' on each file; see that function for details.  When
invoked interactively, you are prompted for a list of files to convert,
terminated with RET.

If TARGET-DIRECTORY is specified, the HTML files will be saved to that
directory.  Normally, each HTML file is saved to the directory of the
corresponding source file."
  (interactive
   (list
    (let (list file)
      ;; Use empty string as DEFAULT because setting DEFAULT to nil
      ;; defaults to the directory name, which is not what we want.
      (while (not (equal (setq file (read-file-name
				     "HTML-ize file (RET to finish): "
				     (and list (file-name-directory
						(car list)))
				     "" t))
			 ""))
	(push file list))
      (nreverse list))))
  ;; Verify that TARGET-DIRECTORY is indeed a directory.  If it's a
  ;; file, xhtmlize-file will use it as target, and that doesn't make
  ;; sense.
  (and target-directory
       (not (file-directory-p target-directory))
       (error "target-directory must name a directory: %s" target-directory))
  (dolist (file files)
    (xhtmlize-file file target-directory)))

;;;###autoload
(defun xhtmlize-many-files-dired (arg &optional target-directory)
  "Xhtmlize dired-marked files."
  (interactive "P")
  (xhtmlize-many-files (dired-get-marked-files nil arg) target-directory))

(provide 'xhtmlize)

;;; xhtmlize.el ends here
