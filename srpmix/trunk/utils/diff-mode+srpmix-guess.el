;;; diff-mode+srpmix-guess.el --- in diff-mode guessing the path of source code installed with srpmix 

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
(provide 'diff-mode+srpmix-guess)
;; diff-mode+srpmix-guess.el ends here