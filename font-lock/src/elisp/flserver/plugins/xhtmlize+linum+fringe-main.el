(require 'xhtml-linum-fringe-decl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Handle zero with overlays like linum
;;
;;
;; Insert pseudo fringe
;;
;; (when (bolp)
;;   (funcall insert-text-with-id-method 
;; 	     " "
;; 	     (concat "P:" (number-to-string (point))
;; 		     ";"
;; 		     "L:" (number-to-string (line-number-at-pos))
;; 		     )
;; 	     nil
;; 	     (mapcar (lambda (f)
;; 		       (gethash f face-map))
;; 		     (list 'fringe))
;; 	     htmlbuf))
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'xhtml-linum-fringe-main)