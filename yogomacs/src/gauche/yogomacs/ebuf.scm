(define-module yogomacs.ebuf
  (export find-file!
	  line-for
	  search-forward))

(select-module yogomacs.ebuf)

(define-class <ebuf> ()
  ((string)
   (point->line)))

(define-method find-file! ((buf <ebuf>)
			   (file-name <string>))
  
  )

(define-method line-for ((buf <ebuf>)
			 (point <integer>))
  )

(define-method search-forward ((buf <ebuf>)
			       (string <string>)
			       (start-from <point>))
  ;; 
  )

(provide "yogomacs/ebuf")