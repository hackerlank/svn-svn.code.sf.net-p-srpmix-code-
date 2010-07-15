(define-module yogomacs.renderers.cache
   (export cache)
   (use yogomacs.renderer)
   (use yogomacs.access)
   (use yogomacs.caches.shtml))

(select-module yogomacs.renderers.cache)

(define (cache src-path prepare-proc namespace config)
  (unless (readable? src-path)
    (not-found "File Not Found" src-path))
  (do-shtml-cache src-path
		  ;; TODO: Here I should injenct rederer own error raisers.
		  (pa$ prepare-proc src-path config)
		  namespace
		  config))

(provide "yogomacs/renderers/cache")
