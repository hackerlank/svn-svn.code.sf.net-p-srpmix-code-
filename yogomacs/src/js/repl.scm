;;
;; Repl
;;
(define *message* #f)
(define (current-message) *message*)
(define (message . args)
  (if (null? args)
      (begin
	(set! *message* #f)
	(-> "" "minibuffer"))
      (let1 msg (apply format args)
	(set! *message* msg)
	(->  msg "minibuffer"))))

(define *shell-dir* #f)
(define *shell* #f)
(define *shell-eval* #f)

(define (repl-init)
  (let1 shell (read-meta "shell")
    (cond
     ((eq? shell 'ysh)
      (ysh-init))
     (else
      (nologin-init)))))

(define (repl-eval)
  (let1 in (<- "minibuffer")
    (let1 out (with-error-handler
		write-to-string
		(pa$ *shell-eval* in))
      (-> out "minibuffer")))
  (let1 elt ($ "minibuffer")
    (elt.focus)
    (elt.select)))

(define (repl-set-prompt! sxml)
  (let1 prompt ($ "minibuffer-prompt")
    (prompt.update (sxml->xhtml sxml))))

(define (ysh-init)
  (set! *shell-dir* "/ysh")
  (set! *shell* 'ysh)
  (set! *shell-eval* ysh-eval)
  (repl-set-prompt! "M-x"))

(define (ysh-eval str)
  "; Not implemented")

;(define-macro (define-reader name params)...)
;(define-macro (define-command name 
;		((params <type>)
;		 )
;		...))
;(define-macro (define-reporter ...))

(define (nologin-init)
  (set! *shell-dir* "")
  (set! *shell 'nologin)
  (set! *shell-eval* nologin-eval))
(define (nologin-eval)
  #f)
