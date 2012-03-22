;; srpmix-guess.el --- Guessing paths for file installed with srpmix in various situations

;; Copyright (C) 2009 Masatake YAMATO

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


;;
;; For etags
;;
(defvar etags+srpmix-guess-original-visit-tags-table nil)
(defun etags+srpmix-guess-search-tags-file (base)
  (unless (equal base "/")
    (let ((upper (file-name-directory base)))
      (cond
       ((not upper)
	nil)
       ;; srpmix
       ((or (file-exists-p (concat upper "plugins/kindex/x86_64.TAGS"))
	    (file-exists-p (concat upper "plugins/kindex/i686.TAGS"))
	    (file-exists-p (concat upper "plugins/kindex/generic.TAGS")))
	(concat upper "plugins/kindex/"))
       ((file-exists-p (concat upper "plugins/etags/TAGS"))
	(concat upper "plugins/etags/"))
       ;; lcopy
       ((file-exists-p (concat upper ".lcopy/TAGS"))
	(concat upper ".lcopy/"))
       ;; lcopy NG
       ((file-exists-p (concat upper ".lcopy/plugins/etags/TAGS"))
	(concat upper ".lcopy/plugins/etags/"))
       (t
	(etags+srpmix-guess-search-tags-file (directory-file-name upper)))))))
(defun etags+srpmix-guess-visit-tags-table (file &optional local)
  (interactive (list nil nil))
  (if file
      (etags+srpmix-guess-original-visit-tags-table file)
    (let ((in-stitch (etags+srpmix-guess-search-tags-file default-directory)))
      (let ((default-directory (or in-stitch default-directory)))
	(call-interactively 'etags+srpmix-guess-original-visit-tags-table)))))

(eval-after-load
    "etags"
  '(progn
     (unless (fboundp 'etags+srpmix-guess-original-visit-tags-table)
       (fset 'etags+srpmix-guess-original-visit-tags-table
	     (symbol-function 'visit-tags-table)))
     (fset 'visit-tags-table 
	   (symbol-function 'etags+srpmix-guess-visit-tags-table))))

;;
;; Under Diff-mode
;;
(eval-after-load
    "diff-mode"
  '(defadvice diff-find-file-name (around srpmix-guess activate)
    (let ((default-directory (if (string-match "/archives/$" default-directory)
				 (file-name-as-directory
				  (concat (file-name-directory 
					   (directory-file-name default-directory))
					  "pre-build"))
			       default-directory)))
      ad-do-it)))


;;
;; Rpm spec mode
;;
(add-hook 'rpm-spec-mode-hook
	  (lambda ()
	    (define-key rpm-spec-mode-map "\C-cj" 'rpm-jump-to-patch-file)))

(defun rpm-jump-to-patch-file ()
  (interactive)
  (let ((file (save-excursion
		(beginning-of-line)
		(cond
		 ((looking-at "Patch[0-9]+:\\s-*\\(.*\\)")
		  (match-string 1))
		 ((looking-at "%patch\\([0-9]+\\)")
		  (let ((pnum (match-string 1)))
		    (goto-char (point-min))
		    (if (re-search-forward (format "Patch%s:" pnum)
					   nil
					   t)
			(rpm-jump-to-patch-file)
		      nil)))
		 ((and (looking-at "- \\[\\([^]]*\\)\\] \\(.*\\) ([^)]+) \\[[0-9]+\\]")
		       (let* ((pat (concat "^Patch[0-9]+:\\s-*\\(.*"
					   (regexp-quote (concat
							  (match-string 1)
							  "-" 
							  (replace-regexp-in-string "[ \t]" "-" (match-string 2))))
					   ".*\\)"))
			      (p (re-search-backward pat nil t)))
			 p))
		  (match-string 1))
		 (t
		  nil)))))
    (if file
	(srpmix-find-file-in-archives file)
      (error "Cannot patch line"))))

(defun srpmix-find-file-in-archives (file)
  (find-file (format "./%s/%s" 
		     "archives"
		     file)))


;;
;; Cscope
;;
(eval-after-load "xcscope"
  '(defadvice cscope-search-directory-hierarchy (around srpmix-guess activate)
     (let ((result ad-do-it))
       (setq ad-return-value
	     (cond
	      ((and (not (equal result "/"))
		    ;; ???
		    (not (equal result (ad-get-arg 0))))
	       result)
	      (t (cscope+srpmix-search-directory-hierarchy (ad-get-arg 0)))
	      )))))

(eval-after-load "xcscope"
  '(defadvice cscope-insert-with-text-properties (around srpmix-guess activate)
     (let ((f_ (ad-get-arg 1)))
       (ad-set-arg 1 (if (string-match "\\(.*\\)plugins/cscope/\\(.*\\)" f_)
			 (concat (match-string 1 f_) (match-string 2 f_))
		       f_)))
     ad-do-it))

(defun cscope+srpmix-search-directory-hierarchy (base)
  (if (equal base "/")
      base
    (let ((upper (file-name-directory base)))
      (cond
       ((not upper) "/")
       ((or (file-exists-p (concat upper "plugins/cscope/cscope.files")))
	(concat upper "plugins/cscope/"))
       (t (cscope+srpmix-search-directory-hierarchy (directory-file-name upper)))))))
  
	   
;;
;; TODO: Vc-mode(C-xv=)
;;
(provide 'srpmix-guess)
;; srpmix-guess.el ends here
