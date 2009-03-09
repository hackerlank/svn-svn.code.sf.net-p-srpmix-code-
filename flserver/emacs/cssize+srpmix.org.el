(require 'cssize)
;(require 'srpmix-config)

(defun ccsize+srpmix-defined-p (face dir)
  (let ((file (concat (cssize-clean-up-face-name face) ".css")))
    (let ((path (concat (file-name-as-directory dir) file)))
      (file-readable-p path))))
(defun ccsize+srpmix-save (face dir)
  (let ((file (concat (cssize-clean-up-face-name face) ".css")))
    (let ((path (concat (file-name-as-directory dir) file)))
      (let ((buffer  (find-file-noselect path)))
	(with-current-buffer buffer
	  (erase-buffer)
	  (insert (cssize-face-to-css face))
	  (save-buffer))
	(kill-buffer buffer)))))

;; TODO: COPYRIGHT NOTICE
;(mapc
; (lambda (face)
;   (ccsize+srpmix-save face "/tmp"))
; (face-list))
(provide 'cssize+srpmix)