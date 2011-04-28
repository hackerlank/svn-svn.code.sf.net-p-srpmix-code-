(define-module yogomacs.renderers.yogomacs
  (export yogomacs)
  (use text.html-lite)
  (use srfi-1)
  (use util.list)
  (use yogomacs.path)
  (use yogomacs.shell)
  (use yogomacs.window)
  (use yogomacs.config)
  )

(select-module yogomacs.renderers.yogomacs)

(define (insert-user-info params)
  (let1 user (params "user")
	(let ((user-name (if user (ref user 'name) #f))
	      (user-real-name (if user (ref user 'real-name) #f)))
	  (list 
	   `(define (user-name) ,user-name)
	   `(define (user-real-name) ,user-real-name)))))

(define (insert-role-info params)
  (let1 role (params "role")
    (let1 role-name (or role  #f)
      (list
       `(define (role-name) ,role-name)))))

(define (extra-scripts url current-params next-params shell)
  
  `((add-hook find-file-pre-hook (pa$ load-lazy ,url ,next-params))
    (add-hook find-file-pre-hook ,(ref shell 'initializer))
    (add-hook toggle-full-screen-hook toggle-full-screen)
    (add-hook read-from-minibuffer-hook ,(ref shell 'interpreter))
    ,@(insert-user-info current-params)
    ,@(insert-role-info current-params)
    ))

(define (yogomacs path params shell)
  (yogomacs0 path params shell
	     '(("yogomacs--Default.css" . "Default")
	       ("yogomacs--Invert.css" . "Invert"))
	     `(
	       (,#`"yogomacs-,(version)-,(release).js" . file)
	       )))

(define (yogomacs0 path params shell css-list js-list)
  (let* ((shell-name (ref shell 'name))
	 (title (compose-path path))
	 (url title)
	 (next-params #`"yogomacs=,|shell-name|")
	 (next-params (or (and-let* ((range (params "range")))
			    (format "range=~a&~a"  (html-escape-string range) next-params))
			  next-params))
	 (next-params (or (and-let* ((enum (params "enum")))
			    (format "enum=~a&~a"  (html-escape-string enum) next-params))
			  next-params))
	 (js-list (reverse (cons `(,(extra-scripts url params next-params shell) . inline)
				 (reverse
				  js-list))))
	 (prompt (ref shell 'prompt))
	 )
    (window title url css-list js-list shell-name prompt)))

(provide "yogomacs/renderers/yogomacs")