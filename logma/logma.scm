(use srfi-19)


(define (read-line-safe)
  (guard (e
	  (else ""))
	 (read-line)))

(define (print-help prog status)
  (display "Usage: \n")
  (format #t "	~s DELTA\n" prog)
  (format #t "	~s --help\n" prog)
  (exit status))

(define (rearrange date-string delta)
  (date->string 
   (time-utc->date
    (add-duration (date->time-utc
		   (string->date (string-append 
				  (date->string (time-utc->date (current-time)) "~y")
				  " " date-string) "~y ~b ~d ~H:~M:~S"))
		  delta))
   "~b ~d ~H:~M:~S"))

(define (main args)
  (unless (eq? 2 (length args))
    (with-output-to-port (current-error-port)
      (cute print-help (car args) 1)))
  (when (or (equal? (cadr args) "-h")
	    (equal? (cadr args) "--help"))
    (print-help (car args) 0))

  (let1 delta (let1 d (string->number (cadr args))
		(unless d
		  (with-output-to-port (current-error-port)
		    (cute print-help (car args) 1)))
		(make <time> :type 'time-duration :second d))
    (let loop ((l (read-line-safe)))
      (unless (eof-object? l)
	(rxmatch-cond
	  ((#/^([A-Z][a-z][a-z] [0-9]+ [0-9]{2}:[0-9]{2}:[0-9]{2}) ([-a-z0-9]+) ([^\[\]\/]+)(\[[0-9]+\])?: (.*)$/ l)
	   (#f date host cmd pid msg)
	   (format #t
		   "~a ~a ~a ~a: ~a\n"
		   (rearrange date delta)
		   host
		   cmd
		   (or pid "")
		   msg
		   )))
	(loop (read-line-safe))))))

