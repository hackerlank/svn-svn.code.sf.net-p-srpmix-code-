;;; rpm-spec-mode+srpmix-jump.el --- Jump to the patch file from patch line

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
		 (t
		  nil)))))
    (if file
	(srpmix-find-file-in-archives file)
      (error "Cannot patch line"))))

(defun srpmix-find-file-in-archives (file)
  (find-file (format "./%s/%s" 
		     "archives"
		     file)))

(provide 'rpm-spec-mode+srpmix-jump)
;; rpm-spec-mode+srpmix-guess.el ends here