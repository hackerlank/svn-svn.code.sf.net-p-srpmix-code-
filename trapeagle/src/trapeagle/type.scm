(define-module trapeagle.type
  (export type-format-params-of
	  type-count
	  type-pos-of
	  type-actual-params-for))
(select-module trapeagle.type)

(define type-counter (let1 i 0 (lambda (inc?) (let1 r i (when inc? (inc! i)) r))))
(define type-count (pa$ type-counter #f))

(define type-infos (make-hash-table 'eq?)) ; [pos formal-params]
(define-macro (deftype type formal-params)
  (let1 v (ref type-infos type (make-vector 4 #f))
    (vector-set! v 0 type)
    (unless (ref v 1)
      (vector-set! v 1 (type-counter #t)))
    (vector-set! v 2 formal-params)
    (set! (ref type-infos type) v)
    (let1 pickers (map (lambda (param)
			 (lambda (strace)
			   strace
			   (get-keyword (make-keyword (symbol->string param)) strace)))
		       formal-params)
    `(vector-set! ,v 3 (lambda (strace)
			 (list ,@(map (lambda (p) `(,p strace)) pickers)))))))

(define (type-format-params-of type)
  (vector-ref (hash-table-get type-infos type) 2))
(define (type-pos-of type)
  (vector-ref (hash-table-get type-infos type) 1))
(define (type-actual-params-for type strace)
  ((vector-ref (hash-table-get type-infos type) 3) strace))

(deftype trace (pid xargs xrvalue xerrno time index))
(deftype unfinished (pid resumed? time index))
(deftype resumed (pid xargs xrvalue xerrno unfinished? time index))
(deftype unfinished-exit (pid))	; TODO

(provide "trapeagle/type")
