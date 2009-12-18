(use srfi-19)


(define (read-line-safe)
  (guard (e
	  (else ""))
	 (read-line)))

(define (main args)
  (let loop ((l (read-line-safe)))
    (unless (eof-object? l)
      ;; Dec 14 16:56:29 host xinetd[2559]: START: ndtp pid=16222 from=::ffff:127.0.0.1
;      (print l)
      (rxmatch-cond
	((#/^([A-Z][a-z][a-z] [0-9]+ [0-9]{2}:[0-9]{2}:[0-9]{2}) ([-a-z0-9]+) ([^\[\]\/]+)(\[[0-9]+\])?: (.*)$/ l)
	 (#f date host cmd pid msg)
	 (print (string->date (string-append 
			       (date->string (time-utc->date (current-time)) "~y")
			       " "date) "~y ~b ~d ~H:~M:~S"))
	 ))
      (loop (read-line-safe)))))

