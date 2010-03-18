(define-module trapeagle.serialize
  (export <serializer>))
(select-module trapeagle.serialize)

(define-class <serializer> ()
  ((input-port :init-keyword :input-port
	       :init-form (current-input-port))
   (tag   :init-keyword :tag
	  :init-value :index)
   (index :init-keyword :start-index
	  :init-value 0)))

(define-method read ((serializer <serializer>))
  (let1 r (read (ref serializer 'input-port))
    (if (eof-object? r)
	r
	(let1 r (append! r 
			 (list (ref serializer 'tag) 
			       (ref serializer 'index)))
	  (inc! (ref serializer 'index))
	  r))))

(provide "trapeagle/serialize")
