(define-module yogomacs.cache
   (export cache-kernel))

(select-module yogomacs.cache)


;;
;; (available?):    returns implicit cache object if available.
;;                  #f means making cache object force.
;;
;; (prepare!):      returns implicit cache object. This is called
;;                  if available? returns #f or available? is #f.
;;
;; (deliver CACHE):   converts CACHE object to usable form.
;;                  if deliver is #f, cache-kernel returns the 
;;                  value returned from available? or prepare!.
;;

(define (do-if-exists handler val)
   (if handler
       (handler val)
       val))

(define (prepare-and-deliver prepare! deliver)
   (if prepare!
       (let1 obj (prepare!)
	     (if obj
		 (do-if-exists deliver obj)
		 obj))
       obj))

(define (cache-kernel available? prepare! deliver)
   (if available?
       (let1 obj (available?)
	     (if obj
		 (do-if-exists deliver obj)
		 (prepare-and-deliver prepare! deliver)))
       (if prepare!
	   (prepare-and-deliver prepare! deliver)
	   #f)))

(provide "yogomacs/cache")