(defun time-command ()
  (interactive)
  (let ((t0 (current-time)))
    (call-interactively 'execute-extended-command)
    (message "Time: %s" (float-time (time-subtract (current-time) t0)))))

(defun time-expr (expr)
  (interactive "xEval: ")
  (let ((t0 (current-time)))
    (eval expr)
    (message "Time: %s" (float-time (time-subtract (current-time) t0)))))

(provide 'time)