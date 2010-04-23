;; Derived from list.el
(defun narrow-to-defun+ (&optional arg)
  "Make text outside current defun invisible.
The defun visible is the one that contains point or follows point.
If Optional integer ARG is  given, only portion of the defun is visible;
If ARG > 0, the region between the beginning of line where the point is
to the end of defun. 
If ARG < 0, the region between the beginning of defun to the end of line
where the point is."
  (interactive "P")
  (unless arg
    (setq arg 0))
  (save-excursion
    (widen)
    (let ((opoint (point))
	  beg end)
      ;; Try first in this order for the sake of languages with nested
      ;; functions where several can end at the same place as with
      ;; the offside rule, e.g. Python.
      (cond 
       ((eq arg 0)
	(beginning-of-defun)
	(setq beg (point))
	(end-of-defun)
	(setq end (point)))
       ((< arg 0)
	(setq end (line-end-position))
	(beginning-of-defun)
	(setq beg (point))
	(goto-char opoint))
       (t
	(setq beg (line-beginning-position))
	(end-of-defun)
	(setq end (point))))
      (while (looking-at "^\n")
	(forward-line 1))

      (unless (> (point) opoint)
	;; beginning-of-defun moved back one defun
	;; so we got the wrong one.
	(when (eq arg 0)
	  (goto-char opoint)
	  (end-of-defun)
	  (setq end (point))
	  (beginning-of-defun)
	  (setq beg (point))))

      (goto-char end)
      (re-search-backward "^\n" (- (point) 1) t)
      (narrow-to-region beg end))))

(defmacro with-narrow-to-defun+ (dir &rest body)
  `(save-restriction
     (narrow-to-defun+ ,dir)
     ,@body))

(defmacro define-narrow-to-defun-command0 (cmd arg post-fix)
  `(defun ,(intern (concat (symbol-name cmd) post-fix)) ()
     (interactive)
     (with-narrow-to-defun+ ,arg (call-interactively ',cmd))))

(defmacro define-narrow-to-defun-command (cmd)
  `(progn
     (define-narrow-to-defun-command0 ,cmd -1 "-backward")
     (define-narrow-to-defun-command0 ,cmd 1 "-forward")))


(define-narrow-to-defun-command occur)
;;; lisp.el --- Lisp editing commands for Emacs

;; Copyright (C) 1985, 1986, 1994, 2000, 2001, 2002, 2003, 2004,
;;   2005, 2006, 2007, 2008 Free Software Foundation, Inc.

;; Maintainer: FSF
;; Keywords: lisp, languages

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.
