(define-module yogomacs.util.ebuf 
  (export <ebuf> 
	  find-file!
	  insert!
	  line-for
	  search-forward)
  (use srfi-13))

(select-module yogomacs.util.ebuf)

(define-class <ebuf> ()
  ((buffer-string)
   (point-max)
   (newline-points)))

(define (newline-points str)
  (reverse (let loop ((point 0)
		      (newline-points (list)))
	     (let1 np (string-index str #\newline point)
	       (if np
		   (loop (+ np 1) (cons np newline-points))
		   newline-points)))))

(define-method find-file! ((buf <ebuf>)
			   (file-name <string>))
  (let* ((str (call-with-input-file file-name port->string))
	 (pmax (string-length str)))
    (set! (ref buf 'buffer-string) str)
    (set! (ref buf 'point-max) pmax)
    (set! (ref buf 'newline-points) (newline-points str))))

(define-method insert! ((buf <ebuf>)
			(str <string>))
  (set! (ref buf 'buffer-string) str)
  (set! (ref buf 'point-max) (string-length str))
  (set! (ref buf 'newline-points) (newline-points str)))


(define-method line-for ((buf <ebuf>)
			 (point <boolean>))
  #f)

(define-method line-for ((buf <ebuf>)
			 (point <integer>))
  (let1 point (- point 1)
    (if (or (< point 0) (< (ref buf 'point-max) point))
	(values #f #f)
	(let loop ((newline-points (ref buf 'newline-points))
		   (last-newline 0)
		   (count-newline 1))
	  (if (null? newline-points)
	      (values count-newline (- point last-newline))
	      (let1 current-newline-point (car newline-points)
		(if (< point current-newline-point)
		    (values count-newline (- point last-newline))
		    (loop (cdr newline-points) current-newline-point (+ count-newline 1)))))))))

(define-method search-forward ((buf <ebuf>)
			       (string <string>)
			       (start-from <integer>))
  (string-contains (ref buf 'buffer-string)
		   string
		   start-from))

(provide "yogomacs/util/ebuf")