(define-module yogomacs.renderers.outlang
  (export outlang)
  (use outlang.outlang)
  (use yogomacs.access)
  (use yogomacs.error)
  (use file.util)
  ;;
  (use sxml.tree-trans)
  (use util.list)
  (use srfi-1)
  )
(select-module yogomacs.renderers.outlang)

(define asis `((*text* . ,(lambda (tag str) str))
	       (*default* . ,(lambda x x))))

(define (fold-refs base-dir shtml config)
  (pre-post-order shtml
		  `((a . ,(lambda (tag attr val)
			    (when (and (list? attr)
				       (not (null? attr))
				       (eq? (car attr) '|@|)
				       (let1 type (car (assq-ref attr 'class '(#f)))
					 (or (equal?  type "postline-reference")
					     (equal?  type "inline-reference"))))
			      (let* ((cel (assq 'href attr))
				     (val-cel (cdr cel)))
				(set-car! val-cel (build-path base-dir "pre-build" (car val-cel)))))
				(list tag attr val)))
		    ,@asis)))

(define (outlang src-path config)
  (if (readable? src-path)
      (let* ((shtml (apply (with-module outlang.outlang outlang)
			   src-path (extra-args src-path config)))
	     (base-dir (split-at-pre-build src-path)))
	(if shtml
	    (if base-dir
		(fold-refs (substring base-dir
				      (string-length (config 'real-sources-dir))
				      (string-length base-dir))
			   shtml config)
		shtml)
	    (internal-error "Cannot handle the source file"
			    src-path)))
      (not-found "File not found"
		 src-path)))

(define (extra-args src-path config)
  (let ((nctags (find-nctags-for src-path config)))
    (if (and #f nctags)
	`(:ctags ,nctags)
	'())))

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
  (let1 m (#/(.*)\/pre-build(|\/.*)$/ src-path)
    (if m
	(values (m 1) (m 2))
        (values #f #f))))

(provide "yogomacs/renderers/outlang")
