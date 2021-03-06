(define-module trapeagle.pre.serialize
  (export <serializer>
	  read)
  (use trapeagle.pre-common))

(select-module trapeagle.pre.serialize)

(define-class <serializer> ()
  ((input-port :init-keyword :input-port
	       :init-form (current-input-port))
   (tag   :init-keyword :tag
	  :init-value :index)
   (index :init-keyword :start-index
	  :init-value 0)
   (debug :init-keyword :debug
	  :init-value #f)))

(define-method read ((serializer <serializer>))
  (let1 r (read (ref serializer 'input-port))
    (when (ref serializer 'debug)
       (format (current-error-port) ";; <serializer> ~d\n" (ref serializer 'index)))
    (if (eof-object? r)
	r
	(if (eq? (car r) 'strace)
	    (let1 r (if (memq (ref serializer 'tag) r)
			r
			(let1 r (append! r 
					 (list (ref serializer 'tag) 
					       (ref serializer 'index)))
			  r))
	      (inc! (ref serializer 'index))
	      r)
	    r))))

(provide "trapeagle/pre/serialize")
