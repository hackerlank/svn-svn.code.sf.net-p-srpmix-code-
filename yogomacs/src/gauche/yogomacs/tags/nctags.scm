(define-module yogomacs.tags.nctags
  (use yogomacs.tag)
  (use yogomacs.access)
  (use yogomacs.path)
  (use file.util)
  (use util.list)
  ;;
  (use gauche.process)
  ;;
  (use es.src.ctags-command)
  (use yogomacs.major-mode)
  )

(select-module yogomacs.tags.nctags)

(define (nctags-has-tag? name real-src-path params config)
  (find-nctags-for real-src-path config))

(define (find-nctags-for src-path config)
  (receive (base-dir dummy) (split-at-pre-build src-path)
    (if base-dir
	(let1 tags-file (build-path base-dir "plugins" "nctags" "tags")
	  (if (and 
	       (directory? base-dir "plugins")
	       (directory? (build-path base-dir "plugins") "nctags")
	       (readable? tags-file))
	      tags-file
	      #f))
	#f)))

(define (split-at-pre-build src-path)
  (let1 m (#/(.*)\/pre-build(|\/.*)$/ src-path) ; |
    (if m
	(values (m 1) (m 2))
        (values #f #f))))

(define (nctags-tag-for name real-src-path params config)
  (if-let1 nctags (find-nctags-for real-src-path config)
	   (cond 
	    ((and (equal? (params "main-key") "symbol")
		  (params "symbol")) => (lambda (symbol)
					  (map (cut conv
						    <> 
						    real-src-path
						    symbol 
						    params
						    config)
					       (ctags-for-symbol nctags symbol))))
	    (else (list)))
	   (list)))

;; <= (nctags :target symbol :url "..." :short-desc "..." :desc "..." :local?  ... :score ...)
;; => (ctags :name ... :file ... :line ... :scope ... :kind ... :extra (...))
;; (ctags :version "0" :name "A11_MARK" :file "linux-2.6/arch/sh/kernel/cpu/sh4a/pinmux-sh7757.c" :line 506 :scope #t :kind e :extra ())
;; (nctags :url "/sources/k/kernel/^lcopy-trunk/pre-build/linux-2.6/arch/sh/kernel/cpu/sh4a/pinmux-sh7757.c#L:506"
;;         :short-desc "enumerators, file local"
;;         :desc #f
;;         :local? #t
;;         :score 51)
;; 
(define (extra->major-mode extra)
  (if-let1 lang (get-keyword :language extra #f)
	   (normalize-major-mode (string-append lang "-mode"))
	   #f))

(define (conv es real-src-path symbol params config)
  (let-keywords (cdr es)
      ((file 'file)
       (line 'line)
       (scope 'scope)
       (kind 'kind)
       (extra 'extra)
       . #f)
    (let* ((real-def-path (build-path (values-ref (split-at-pre-build 
						   real-src-path) 
						  0)
				      "pre-build"
				      file))
	   (path-distance (path-distance real-src-path real-def-path))
	   (major-mode-in-request (params "major-mode")))
      `(nctags 
	:target (symbol ,symbol)
	:url ,#`",(real->web real-def-path config)#L:,|line|"
	:preview-url ,#`",(real->web real-def-path config)"
	:preview-params ,(let* ((len 4)
				(start (if (< line 2) line (- line 1)))
				(end (if (< line 2) (+ line len) (+ line len -1))))
			   `((range . ,#`",|start|-,|end|")
			     ;; TODO
			     (shell . "preview")
			     ))
	:short-desc ,kind
	:desc ,(make-desc kind major-mode-in-request extra)
	:local? #t
	:score ,(make-score real-src-path
			    real-def-path
			    scope
			    major-mode-in-request
			    extra)))))

(define (make-desc kind major-mode-in-request extra)
  (define (desc-of kind major-mode)
    (if major-mode
	(let1 kinds (assoc-ref (kinds-list)
			       major-mode
			       (list))
	  (let1 desc (car (assq-ref kinds kind '(#f)))
	    desc))
	#f))
  (string-append (or (any (pa$ desc-of kind) (list (extra->major-mode extra)
						   major-mode-in-request
						   "c-mode"))
			  "???")
		 (write-to-string extra)))

(define (make-score real-src-path
		    real-def-path
		    scope
		    major-mode-in-request
		    extra)
  (let1 same-file? (equal? real-def-path real-src-path)
    (+ 50 
       (if (equal? real-def-path real-src-path)
	   1
	   0)
       (if (and (equal? real-def-path real-src-path) scope )
	   3
	   0) 
       (if (equal? (extra->major-mode extra) 
		   major-mode-in-request)
	   1 0))))

(define kinds-list
  (let1 val #f
    (lambda ()
      (if val
	  val
	  (begin
	    (set! val
		  (map (lambda (entry)
			 (let1 mode (normalize-major-mode (string-append (car entry) "-mode"))
			   (cons mode (cdr entry))))
		       (cdr (es<-ctags-command 'kinds))))
	    val)))))

(define (ctags-for-symbol nctags symbol)
  (let* ((proc (run-process
		 `(es-src-ctags
		   ,#`"--tagfile=,|nctags|"
		   ,#`"--find=,|symbol|")
		 :output :pipe))
	  (output (process-output proc)))
     (let loop ((es (read output))
		(result (list)))
       (if (eof-object? es)
	   (begin
	     (process-wait proc)
	     (if (eq? (process-exit-status proc) 0)
		 (reverse result)
		 (list)			;???
		 ))
	   (loop (read output)
		 (cons 
		  es
		  result))))))

(define (path-distance from to)
  ;; TODO
  0)

(define-tag-handler nctags
  :has-tag? nctags-has-tag?
  :tag-for nctags-tag-for)

(provide "yogomacs/tags/nctags")
