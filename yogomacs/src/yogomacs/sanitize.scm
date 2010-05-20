(define-module yogomacs.sanitize
  (export 
   sanitize-path
   )
  (use file.util))
(select-module yogomacs.sanitize)

(define (sanitize-path path)
  (let* ((simplified (simplify-path path))
	 (basename (sys-basename simplified))
	 (dirname (sys-dirname simplified))
	 (_ (build-path dirname basename))
	 (sanitized (if (equal? _ ".") "/" _)))
    sanitized))
    
(provide "yogomacs/sanitize")