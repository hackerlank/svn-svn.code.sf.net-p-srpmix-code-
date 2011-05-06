(define (fundamental-symbol-at target offset-rate)
  (let1 str target.innerHTML
    (let* ((separators (major-mode-of 'separators))
	   (split-pos (inexact->exact (ceiling (* offset-rate 
						  (string-length str)))))
	   (before (substring-before str split-pos))
	   (after (substring-after str split-pos))
	   (before-filtered (let loop ((before (reverse (string->list before)))
				       (result (list)))
			      (cond
			       ((null? before)
				(list->string result))
			       ((member (car before) separators)
				(loop (list) result))
			       (else
				(loop (cdr before) (cons (car before) result))))))
	   (after-filtered (let loop ((after (string->list after))
				      (result (list)))
			     (cond
			      ((null? after)
			       (list->string (reverse result)))
			      ((member (car after) separators)
			       (loop (list) result))
			      (else
			       (loop (cdr after) (cons (car after) result)))))))
      (let1 result (string-append before-filtered after-filtered)
	(if (equal? result "")
	    (values #f #f #f)
	    (values result
		    (- split-pos (string-length before-filtered))
		    (+ split-pos (string-length after-filtered)))
	    )))))

(define-major-mode fundamental
  :indicator "Fundamental"
  :separators '(#\space #\tab)
  :symbol-at  fundamental-symbol-at
  )
