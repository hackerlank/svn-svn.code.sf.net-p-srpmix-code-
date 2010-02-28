;; perg.el --- grep.el like frond end for perg
;;
;; Copyright (C) 2010 Masatake YAMATO
;; Copyright (C) 2010 Red Hat, Inc.

;; This library is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This library is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this library.  If not, see <http://www.gnu.org/licenses/>.
;;
;; Author: Masatake YAMATO <yamato@redhat.com>
;;

(defvar perg-database nil)
(defun  perg-set-database (file)
  (interactive "fes-src-xgettext data base file: ")
  (setq perg-database file)
  perg-database)

(defvar perg-log-lines nil)
(defun perg (file pattern)
  (interactive (list
		(if current-prefix-arg
		    (call-interactively 'perg-set-database)
		  perg-database )
		(read-from-minibuffer "Log line: " nil
				      nil nil 'perg-log-lines
				      (buffer-substring (line-beginning-position)
							(line-end-position)))))
  (grep (format "%sperg %s %s" 
		(if (string-match "\\(.*\\)/plugins.*" file)
		    (format "cd %s; " (expand-file-name (match-string 1 file)))
		  "")
		(shell-quote-argument pattern)
		file)))
(provide 'perg)