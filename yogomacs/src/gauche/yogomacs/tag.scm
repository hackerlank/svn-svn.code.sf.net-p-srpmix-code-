(define-module yogomacs.tag
  (export has-tag?
	  define-tag-handler
	  tag-handlers
	  <tag-handler>
	  collect-tags-by-path
	  has-tag?-from-shtml)
  (use util.list)
  (use srfi-1)
  (use sxml.sxpath)
  (use yogomacs.util.sxml)
  )

(select-module yogomacs.tag)

(define-class <tag-handler> ()
  ((has-tag? :init-keyword :has-tag? :init-value #f)
   (tag-for :init-keyword :tag-for :init-value #f)
   ))

(define tag-handlers (make-hash-table 'eq?))
(define-macro (define-tag-handler name . rest)
  `(hash-table-put! tag-handlers ',name
		    (make <tag-handler> ,@rest)))
	  
(define (has-tag? real-src-path params config)
  (hash-table-any 
   (lambda (name obj)
     (if-let1 proc (ref obj 'has-tag?)
	      (proc name real-src-path params config)
	      #f))
   tag-handlers))

;; <= (tag :handler name :url "..." :short-desc "..." :desc "..." :local?  ... :score ...)
(define (collect-tags-by-path real-src-path params config)
  (stable-sort (hash-table-fold tag-handlers
				(lambda (name obj result)
				  (if-let1 proc (and-let* ((proc (ref obj 'has-tag?))
							   ( (proc name real-src-path params config) ))
						  (ref obj 'tag-for))
					   (append (map (pa$ cons* 'tag :handler) 
							(proc name real-src-path params config))
						   result)
					   result))
				(list))
	       comapre-tag))

(define (comapre-tag a b)
  (let ((a-score (get-keyword :score (cdr a) 0))
	(b-score (get-keyword :score (cdr b) 0)))
    (cond 
     ((> a-score b-score)
      #t)
     ((eq? a-score b-score)
      ;; TODO: local?, path distance, url, name...
      #t
      )
     (else
      #f))))

(define (hash-table-any pred ht)
  (any
   (lambda (entry)
     (pred (car entry) (cdr entry)))
   (hash-table->alist ht)))

(define (has-tag?-from-shtml shtml)
  (get-meta-from-shtml shtml "has-tag?"))

(provide "yogomacs/tag")