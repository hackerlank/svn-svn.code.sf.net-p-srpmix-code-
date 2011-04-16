(define-module yogomacs.tags.nctags
  (use yogomacs.tag)
  (use yogomacs.access)
  (use file.util)
  )

(select-module yogomacs.tags.nctags)

(define-tag-handler nctags
  :has-tag? (lambda (name real-src-path config params)
	      (find-nctags-for real-src-path config)))

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

(provide "yogomacs/tags/nctags")