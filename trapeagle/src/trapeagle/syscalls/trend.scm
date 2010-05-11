(define-module trapeagle.syscalls.trend
  (use trapeagle.type)
  (use trapeagle.syscall)
  (use trapeagle.control)
  (export trend)
  )

(select-module trapeagle.syscalls.trend)

(define trend-map  (make-tree-map 
		    eq?
		    (lambda (a b) (string<? (symbol->string a) (symbol->string b)))))

(define-method trend ()
  (map (lambda (elt) (cons (car elt) (exact->inexact (/ (cdr elt) 2)))) (tree-map->alist trend-map)))

(define (inc-trend call v)
  (tree-map-update!
   trend-map
   call
   (lambda (i) (+ i v))
   0))

(defsyscall #t
  :trace (lambda (kernel pid call xargs xrvalue xerrno time index)
	   (inc-trend call 2))
  :unfinished (lambda (kernel pid call xargs xrvalue xerrno resumed? time index)
		(inc-trend call 1))
  :resumed (lambda (kernel pid call xargs xrvalue xerrno unfinished? time index)
	     (inc-trend call 1)))

(provide "trapeagle/syscalls/trend")
