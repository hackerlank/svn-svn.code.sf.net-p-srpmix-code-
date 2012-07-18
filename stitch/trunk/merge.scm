;; -*- scheme -*-
(define (writeln es)
  (write es)
  (newline))

(let loop ((all (list))
	   (elt (read)))
  (if (eof-object? elt)
      (for-each writeln (reverse all))
      (if (member elt all)
	  (loop all (read))
	  (loop (cons elt all) (read)))))
     