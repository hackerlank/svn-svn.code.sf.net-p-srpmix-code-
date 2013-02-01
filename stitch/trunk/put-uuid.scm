;; -*- scheme -*-
(use srfi-1)
(use gauche.process)

(define (writeln es)
  (write es)
  (newline))

(define (rearrange elt)
  (if (memq :uuid elt)
      elt
      (reverse 
       (cons* 
	(process-output->string "uuidgen")
	:uuid (reverse elt)))))

(let loop ((elt (read)))
  (unless (eof-object? elt)
    (case (car elt)
      ('stitch-annotation
       (writeln (rearrange elt)))
       (else
	(writeln elt)))
    (loop (read))))
     
