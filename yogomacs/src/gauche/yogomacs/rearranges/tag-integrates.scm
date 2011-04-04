(define-module yogomacs.rearranges.tag-integrates
  (export tag-integrates)
  (use yogomacs.access)
  (use sxml.tree-trans)
  (use file.util)
  (use srfi-1))

(select-module yogomacs.rearranges.tag-integrates)

(define (tag-integrates sxml real-src-path config)
  (let ((nctags (find-nctags-for real-src-path config)))
    (if (or nctags)
	(pre-post-order sxml
			`((head . ,(lambda (tag . rest)
				     (cons tag (reverse 
						(cons* 
						 `(meta (|@|
							 (name "has-tag?")
							 (content "yes")))
						 "	"
						 (reverse rest))))))
			  (*text* . ,(lambda (tag str) str))
			  (*default* . ,(lambda x x))))
						
	sxml)))

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

(provide "yogomacs/rearranges/tag-integrates")