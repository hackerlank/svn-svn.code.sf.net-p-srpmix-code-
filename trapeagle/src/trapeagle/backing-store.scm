(define-module trapeagle.backing-store
  (export <backing-store>
	  port-tell
	  port-seek
	  write
	  read
	  read-for
	  close
	  ))

(select-module trapeagle.backing-store)
(define-class <backing-store> ()
  (input-port 
   output-port
   file-name
   (template :init-keyword :template)
   (get-key :init-keyword :get-key)
   (pos-table :init-form (make-tree-map eq? <))
   (dirty :init-value #f)
   ))

(define-method initialize ((bs <backing-store>)
			   initargs)
  (next-method)
  (receive (op on) (sys-mkstemp (build-path (temporary-directory) 
					    (ref bs 'template)))
    (set! (ref bs 'output-port) op) 
    (set! (ref bs 'file-name) on)
    (set! (ref bs 'input-port) (open-input-file on))))

(define original-port-tell port-tell)
(define-method port-tell ((port <port>))
  (original-port-tell port))
(define-method port-tell ((bs <backing-store>))
  (port-tell (ref bs 'output-port)))

(define original-write write)
(define-method write (obj)
  (original-write obj))
(define-method write (obj (port <port>))
  (original-write obj port))
(define-method write (obj (bs <backing-store>))
  (let ((key (get-key obj))
	(pos (port-tell bs)))
    (tree-map-put! (ref bs 'pos-table) key pos)
    (write obj (ref bs 'output-port))
    (newline (ref bs 'output-port))
    (set! (ref bs 'dirty) #t)))

(define original-read read)
(define-method read ()
  (original-read))
(define-method read ((port <port>) )
  (original-read port))
(define-method read ((bs <backing-store>))
  (when (ref bs 'dirty)
    (flush (ref bs 'output-port))
    (set! (ref bs 'dirty) #f))
  (read (ref bs 'input-port)))

(define original-port-seek port-seek)
(define-method port-seek ((port <port>) offset)
  (original-port-seek port offset))
(define-method port-seek ((port <port>) whence)
  (original-port-seek port offset whence))
(define-method port-seek ((bs <backing-store>) offset)
  (port-seek (ref bs 'input-port) offset))
(define-method port-seek ((bs <backing-store>) offset whence)
  (port-seek (ref bs 'input-port) offset whence))

(define-method pread ((bs <backing-store>) pos)
  (port-seek bs pos)
  (read bs))

(define-method read-for ((bs <backing-store>) key)
  (pread bs (ref (ref bs 'pos-table) key)))

(define-method close ((bs <backing-store>))
  (close-input-port (ref bs 'input-port))
  (close-output-port (ref bs 'output-port))
  (sys-unlink (ref bs 'file-name)))

(provide "trapeagle/backing-store")
