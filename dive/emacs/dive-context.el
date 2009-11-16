(require 'which-func)

;; =====================================================================
;; Stolen from file `misc-func.el' by Drew Adams.
;; ---------------------------------------------------------------------
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;

;; Stolen from file `intes.el.2'
;;;###autoload
(defun dive-context-current-line ()
  "Current line number of cursor."
  (+ (count-lines (point-min) (point))
     (if (= (current-column) 0) 1 0)))
;; =====================================================================
(defun dive-context-which-function ()
  (condition-case nil
      (which-function)
    (error nil)))

(defun dive-context ()
  (let ((file (buffer-file-name))
	(func (dive-context-which-function))
	(line (dive-context-current-line)))
    `(dive-context :file ,file :func ,func :line ,line)))

(provide 'dive-context)