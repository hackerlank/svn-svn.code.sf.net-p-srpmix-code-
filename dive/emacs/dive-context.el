(require 'which-func)
(require 'dive-tokenize)
(require 'dive-valley)

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

(defvar dive-context-contexts nil)
(defvar dive-context-function nil)
(defun dive-context-update ()
  (unless (local-variable-p 'dive-context-contexts)
    (set (make-local-variable 'dive-context-contexts)
	 (make-hash-table :test 'equal)))
  (unless (local-variable-p 'dive-context-function)
    (set (make-local-variable 'dive-context-function)
	 nil))
  (let* ((func (car (dive-context-which-function)))
	 (context (when func
		    (let ((range (save-excursion 
				   (condition-case nil
				       (beginning-of-defun)
				     (error nil))
				   (let ((b (point)))
				     (let ((e (when (re-search-forward "{" nil t)
						(condition-case nil
						    (progn
						      (end-of-defun)
						      (point))
						  (error nil)))))
				       
				       (if e
					   (list b e)
					 nil))))))
		      (if range
			  (if (and (<= (car range) (point))
				   (<= (point) (cadr range)))
			      (let ((context (gethash func dive-context-contexts)))
				(if context
				    context
				  (let* ((tokens (dive-tokenize-get-expressions (buffer-substring-no-properties 
										 (car range)
										 (cadr range)) 
										(car range)))
					 (valley (dive-valley-new tokens (current-buffer))))
				    (setq context `(dive-context 
						    :file-name ,(buffer-file-name)
						    :line ,(dive-context-current-line)
						    :function ,func
						    :start ,(car range)
						    :end ,(cadr range)
						    :token ,tokens
						    :valley ,valley))
				    (puthash func context dive-context-contexts)
				    context)))
			    (setq func nil)
			    nil)
			(setq func nil)
			nil)))))
    (unless (equal dive-context-function func)
      (setq dive-context-function func)
      ;; TODO
      )
    context))


(provide 'dive-context)