;;
;; Repl
;;
(define shell-dir #f)
(define (message str)
  (-> str "minibuffer"))
(define (repl eval output-prefix)
  (let1 str (<- "minibuffer")
    (let1 result (with-error-handler 
		   write-to-string
		   (pa$ eval str))
      (-> (string-append output-prefix result) "minibuffer")))
  (let1 elt ($ "minibuffer")
    (elt.focus)
    (elt.select)))

(define ysh #f)
(define ysh-dir "/ysh")

(define (ysh-initializer)
  (set! shell-dir ysh-dir))
(define (ysh-eval str)
  "Not implemented")

(define (ysh-interpret)
  (repl ysh-eval "# "))

(define (nologin-initializer)
  (set! shell-dir ""))
(define (nologin-interpret)
  #f)
