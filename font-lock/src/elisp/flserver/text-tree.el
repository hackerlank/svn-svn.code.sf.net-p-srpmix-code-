(defun tree-to-string (tree &optional buffer)
  (while tree
    (cond
     ((stringp (car tree))
      (princ (car tree) (or buffer (current-buffer)))
      (setq tree (cdr tree)))
     ((consp (car tree))
      (tree-to-string (car tree) buffer)
      (setq tree (cdr tree)))
     ((functionp (car tree))
      (tree-to-string (funcall (car tree)) buffer)
      (setq tree (cdr tree)))
     (t
      (error "Cannot handle: %s" (car tree))))))
(provide 'text-tree)

