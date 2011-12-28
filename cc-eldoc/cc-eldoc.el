;;; cc-eldoc.el

;; Copyright (C) 2011 Masatake YAMATO

;; This software is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This software is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with This software.  If not, see <http://www.gnu.org/licenses/>.

(defun c-show-conditional-context ()
  (interactive)
  (let ((context (c-build-conditional-context)))
    (message "%s" (c-render-conditional-context context))))

(defun c-render-conditional-context (context)
  (if context
      (let* ((d 4)
	      (indent (* d -1))
	      (here `(">>HERE<<" :point ,(point) :line ,(line-number-at-pos))))
	 (mapconcat 'identity (mapcar 
			       (lambda (c)
				 (format "%s"
					 (let ((elt (car c)))
					   (cond
					    ((string-match "#[ \t]*if" elt)
					     (setq indent (+ indent d))
					     (concat (make-string indent ?\ ) elt))
					    ((string-match "#[ \t]*elif" elt)
					     (concat (make-string indent ?\ ) elt))
					    ((string-match "#[ \t]*else" elt)
					     (concat (make-string indent ?\ ) elt))
					    (t
					     (setq indent (+ indent d))
					     (concat (make-string indent ?\ ) elt))))))
			       (reverse (cons here (reverse context))))
		    "\n"))
    "<top>"))

(defun c-build-conditional-context ()
  (save-excursion
    (let ((context ()))
      (condition-case nil
	  (while t
	    (c-up-conditional-with-else 1)
	    ;; push
	    (setq context 
		  (cons (let ((p (line-beginning-position)))
			  (list (buffer-substring p (line-end-position))
				:point p
				:line (line-number-at-pos)
				))
			context)))
	(error nil))
      context)))

(defun c-conditional-context-eldoc-function ()
  (c-render-conditional-context
   (c-build-conditional-context)))

(add-hook 'c-mode-hook
	  (lambda ()
	    (set (make-local-variable 'eldoc-documentation-function)
		  #'c-conditional-context-eldoc-function)
	    (turn-on-eldoc-mode)))

(provide 'cc-eldoc)