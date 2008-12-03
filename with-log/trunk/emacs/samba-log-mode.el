;; samba-log-mode.el --- Major mode to browse log files of Samba
;;
;; Copyright (C) 2008 Masatake YAMATO
;; Copyright (C) 2008 Red Hat, Inc.
;;
;; Author: Masatake YAMATO <yamato@redhat.com>
;;
;; This software is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This software is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this software; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.
(require 'add-log)
(require 'log-browse-mode)

(defvar samba-log-font-lock-keywords
  '(("^\\[\\([0-9]\\{4\\}/[0-9]\\{2\\}/[0-9]\\{2\\} [0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}\\), [0-9]+\\] \\([^:]+\\):\\([^(]+\\)([0-9]+)"
     (1 'change-log-date-face)
     (2 'change-log-file)
     (3 'change-log-function)))
  "Additional expressions to highlight in Change Log mode.")

(defvar samba-log-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [return] 'samba-log-jump)
    (define-key map "\C-c\C-c" 'samba-log-jump)
    map)
  "Keymap for Samaba Log major mode.")

(defvar samba-log-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?\" "\"" st)
    (modify-syntax-entry ?\' "\"" st)
    st))

(define-derived-mode samba-log-mode log-browse-mode "Log Browse/Samba"
  "Major mode for Samba log files."
  (set-syntax-table samba-log-mode-syntax-table)
  (set (make-local-variable 'font-lock-defaults)
       '(samba-log-font-lock-keywords nil)))

(defun samba-log-find-tag-noselect (symbol file last-buffer)
  (let ((buffer (find-tag-noselect symbol last-buffer)))
    (when buffer
      (if (string-match (concat (regexp-quote file) "$")  
			(with-current-buffer buffer buffer-file-name))
	  buffer
	(samba-log-find-tag-noselect symbol file buffer)))))

(defun samba-log-jump (file line symbol)
  "Jump from a samba log line to associated source code line.
Before using TAGS file for the source code must be visited."
  (interactive (save-excursion
		 (end-of-line)
		 (if (re-search-backward "\\] \\([^:]+\\):\\([^(]+\\)(\\([0-9]+\\))")
		     (mapcar (lambda (i) (match-string i)) (list 1 3 2))
		   nil)))
  (unless tags-file-name
    (error "No tag file is visited."))
  (if symbol
      (let ((buffer (samba-log-find-tag-noselect symbol file nil)))
	(when buffer
	  (switch-to-buffer-other-window buffer)
	  (goto-line (string-to-number line))))
    (message "Cannot find symbol")))

(provide 'samba-log-mode)

;; samba-log-mode.el ends here.
