;;
;; Repl
;;
(define shell-dir #f)

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

(define (repl eval output-prefix)
  (let1 str (<- "minibuffer")
    (let1 result (with-error-handler 
		   write-to-string
		   (pa$ eval str))
      (-> (string-append output-prefix result) "minibuffer")))
  (let1 elt ($ "minibuffer")
    (elt.focus)
    (elt.select)))

(define (repl-init)
  (let1 shell (read-meta "shell")
    (cond
     ((eq? shell 'ysh)
      (ysh-initializer))
     (else
      ;; ???
      (nologin-initializer)))))

(define (repl-read)
  (let1 shell (read-meta "shell")
    (cond
     ((eq? shell 'ysh)
      (ysh-interpret))
     (else
      ;; ???
      (nologin-interpret)))))

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
