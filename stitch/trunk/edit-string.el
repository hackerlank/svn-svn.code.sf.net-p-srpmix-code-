;;; edit-string.el --- helper for editing elisp literal string

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


(defun edit-string-pick (b e &optional buffer)
  (car (with-current-buffer (or buffer (current-buffer))
	 (read-from-string
	  (buffer-substring b e)))))

(defun edit-string ()
  (interactive)
  (let ((p (syntax-ppss)))
    (if (nth 3 p)
	(let* ((b (nth 8 p))
	       (e (save-excursion
		    (goto-char b)
		    (forward-sexp)
		    (point)))
	       (s (edit-string-pick b e)))
	  (edit-string0 (current-buffer)
			s
			b e))
      (error "point is not in a string literal"))))

(defvar edit-string-target nil)

(defun edit-string0 (target-buffer string begin end)
  (let ((edit-buffer (get-buffer-create (format "[%d %d] @ %s"
						begin
						end
						(buffer-name target-buffer)))))
    (with-current-buffer edit-buffer
      (edit-string-mode)
      (buffer-disable-undo)
      (save-excursion (insert string))
      (buffer-enable-undo)
      (set (make-local-variable 'edit-string-target)
	   (list target-buffer string begin end))
      (pop-to-buffer edit-buffer))))

(define-derived-mode edit-string-mode rst-mode "\"a\""
  "Major mode for edting elisp string literal."
  (let ((m edit-string-mode-map))
    (define-key m "\C-c\C-c" 'edit-string-commit)
    (define-key m "\C-c\C-j" 'edit-string-jump)
    (define-key m "\C-c\C-y" 'edit-string-insert-original)))

(defun edit-string-jump ()
  (interactive)
  (let ((buffer (nth 0 edit-string-target))
	(point (nth 2 edit-string-target)))
    (pop-to-buffer buffer)
    (goto-char point)
    (recenter)))

(defun edit-string-insert-original ()
  (interactive)
  (insert (nth 1 edit-string-target)))

(defun edit-string-commit0 (s b e buf)
  (with-current-buffer buf
    (goto-char b)
    (delete-region b e)
    (prin1 (substring-no-properties s) buf)))

(defun edit-string-commit ()
  (interactive)
  (let* ((tgt edit-string-target)
	 (b (nth 2 tgt))
	 (e (nth 3 tgt))
	 (target-buffer (nth 0 tgt))
	 (current (edit-string-pick b
				    e
				    target-buffer))
	 (orignal (nth 1 tgt))
	 (edit-buffer (current-buffer)))
    (if (equal (substring-no-properties orignal) (substring-no-properties current))
	(progn
	  (edit-string-commit0 (buffer-string)
			       b
			       e
			       target-buffer)
	  (edit-string-jump)
	  (when (y-or-n-p (format "kill the edit buffer: %s" 
				  (buffer-name edit-buffer)))
	    (kill-buffer edit-buffer)))
      (edit-string-jump)
      (error "The target buffer is changed"))))
  
(define-key global-map "\C-xE" 'edit-string)
(provide 'edit-string)
