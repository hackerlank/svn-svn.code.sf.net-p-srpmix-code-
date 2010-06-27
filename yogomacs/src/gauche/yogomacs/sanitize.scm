(define-module yogomacs.sanitize
  (export 
   sanitize-path
   )
  (use file.util)
  (use srfi-1)
  (use yogomacs.path)
  )
(select-module yogomacs.sanitize)
  
(define (sanitize-path path)
  (cond
   ((equal? path "")
    "/")
   ((not (equal? (substring path 0 1) "/"))
    "/")
   (else
    (let* ((simplified (simplify-path path))
	   (basename (sys-basename simplified))
	   (dirname (sys-dirname simplified))
	   (_ (build-path dirname basename))
	   (sanitized (compose-path (remove (cute member <> '(".." ""))
					    (string-split _ #\/)))))
      sanitized))))
    
(provide "yogomacs/sanitize")