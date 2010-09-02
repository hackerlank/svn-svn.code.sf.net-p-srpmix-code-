(define-module yogomacs.command
  (export <command>
	  define-command)
  )

(select-module yogomacs.command)

(define-class <command> ()
  ()
  )

(define-macro (define-command))
;; dest-handler
;; help string
;; biwascheme code


(provide "yogomacs/command")