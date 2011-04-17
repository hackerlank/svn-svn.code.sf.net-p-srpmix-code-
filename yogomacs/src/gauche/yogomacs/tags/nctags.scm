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
  (use srfi-13)
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
	    ((params "symbol") => (lambda (symbol)
				    (map (cute conv
					       <> 
					       real-src-path
					       symbol 
					       (params "major-mode")
					       config)
					 (ctags-for-symbol nctags symbol))))
	    (else (list)))
	   (list)))

;; <= (nctags :target symbol :url "..." :short-desc "..." :desc "..." :local?  ... :score ...)
;; => (ctags :name ... :file ... :line ... :scope ... :kind ...)
;; (ctags :version "0" :name "A11_MARK" :file "linux-2.6/arch/sh/kernel/cpu/sh4a/pinmux-sh7757.c" :line 506 :scope #t :kind e :extra ())
;; (nctags :url "/sources/k/kernel/^lcopy-trunk/pre-build/linux-2.6/arch/sh/kernel/cpu/sh4a/pinmux-sh7757.c#L:506"
;;         :short-desc "enumerators, file local"
;;         :desc #f
;;         :local? #t
;;         :score 51)
;; 
(define (conv es real-src-path symbol major-mode config)
  (let-keywords (cdr es)
      ((file 'file)
       (line 'line)
       (scope 'scope)
       (kind 'kind) . #f)
    (let* ((real-def-path (build-path (values-ref (split-at-pre-build 
						   real-src-path) 
						  0)
				      file))
	   (path-distance (path-distance real-src-path real-def-path)))
      `(nctags 
	:target ,symbol
	:url ,#`",(real->web real-def-path config)#L:,|line|"
	:short-desc ,kind
	:desc ,(kind->desc kind major-mode)
	:local? #t
	:score ,(+ 50 (if scope 
			  (if (equal? real-def-path real-src-path)
			      10
			      -10)
			  0) (if major-mode 1 0))))))

(define (normalize-major-mode name)
  (string-downcase name))

(define kinds-list (map 
		   (lambda (entry)
		     (cons #`",(normalize-major-mode (car entry))-mode"
			   (cdr entry))
		     )
		   (cdr (es<-ctags-command 'kinds))))

(define (kind->desc kind major-mode)
  (let1 kinds (assoc-ref kinds-list 
			 (or major-mode "c-mode")
			 (list))
    (car (assq-ref kinds kind '(#f)))))


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