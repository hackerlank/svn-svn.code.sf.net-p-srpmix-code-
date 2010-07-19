(define-module yogomacs.renderers.cache
   (export cache)
   (use yogomacs.error)
   (use yogomacs.access)
   (use yogomacs.caches.shtml))

(select-module yogomacs.renderers.cache)

(define (cache src-path prepare-proc namespace config)
  (unless (readable? src-path)
    (not-found "File Not Found" src-path))
  (call-with-values
      (pa$ do-shtml-cache src-path
	   (pa$ prepare-proc src-path config)
	   namespace
	   config)
    (lambda r 
      (if (null? (cdr r))
	  (values (car r) #f)
	  (values (car r) (cadr r))))))

(provide "yogomacs/renderers/cache")
