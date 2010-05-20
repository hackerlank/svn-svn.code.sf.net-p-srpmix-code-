(define-module yogomacs.yogomacs
  (export install-yogomacs
	  yogomacs-message)
  )
(select-module yogomacs.yogomacs)

;; TODO Use config
(define (install-yogomacs)
  (list
   "<script src=\"http://yogomacs.org/api/js/biwascheme.js\">\n"
   "(load \"http://yogomacs.org/api/scm/yogomacs.scm\")\n"
   "</script>\n"))

(define (yogomacs-message)
  (list
   "<div class=\"default\" id=\"bs-console\"></div>\n"))

(provide "yogomacs/yogomacs")