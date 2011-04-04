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

(define (outlang src-path config)
  (if (readable? src-path)
      (let1 shtml ((with-module outlang.outlang outlang) src-path)
	(if shtml
	    shtml
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
