;;; etags+srpmix-guess.el --- Guessing the place where plugin/etags/TAGS file is

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


;; Commentary:
;;
;; In Sources environment, TAGS files are stored for somewhere special.
;; 
;; $ ls
;; archives  plugins  pre-build  specs.spec  SRPMIX  STATUS
;; $ ls plugins/
;; etags
;; $ ls plugins/etags
;; TAGS
;; $  
;;
;; Emacs with this elisp program will look for plugins/etags when
;; you invoke `visit-tags-table' in somewhere under archives or 
;; pre-build.
;;

;; INSTALL:
;; (require 'etags+srpmix-guess)

(require 'etags)

(defvar etags+srpmix-guess-original-visit-tags-table nil)
(unless (fboundp 'etags+srpmix-guess-original-visit-tags-table)
  (fset 'etags+srpmix-guess-original-visit-tags-table
	(symbol-function 'visit-tags-table)))

(defun etags+srpmix-guess-search-tags-file (base)
  (unless (equal base "/")
    (let ((upper (file-name-directory base)))
      (cond
       ((not upper)
	nil)
       ;; srpmix
       ((file-exists-p (concat upper "plugins/etags/TAGS"))
	(concat upper "plugins/etags"))
       ;; lcopy
       ((file-exists-p (concat upper ".lcopy/TAGS"))
	(concat upper ".lcopy"))
       ;; lcopy NG
       ((file-exists-p (concat upper ".lcopy/plugins/etags/TAGS"))
	(concat upper ".lcopy/plugins/etags"))
       (t
	(etags+srpmix-guess-search-tags-file (directory-file-name upper)))))))
    
(defun etags+srpmix-guess-visit-tags-table (file &optional local)
  (interactive (list nil nil))
  (if file
      (etags+srpmix-guess-original-visit-tags-table file)
    (let ((in-stitch (etags+srpmix-guess-search-tags-file default-directory)))
      (let ((default-directory (or in-stitch default-directory)))
	(call-interactively 'etags+srpmix-guess-original-visit-tags-table)))))

(fset 'visit-tags-table (symbol-function 'etags+srpmix-guess-visit-tags-table))

(provide 'etags+srpmix-guess)
;; etags+srpmix-guess.el ends here