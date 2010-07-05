;; -*- scheme -*-
(use file.util)
(define report-line-min 5000)

(define (md5sum-path dir)
  (build-path dir "plugins/coreutils/md5sum"))
(define (load-md5sum file)
  (let1 hash-table (make-hash-table 'equal?)
    (with-input-from-file file
      (lambda ()
	(let loop ((l (read-line)))
	  (if (eof-object? l)
	      hash-table
	      (let1 m (#/^([a-f0-9]{32})  (.*)$/ l)
		(set! (ref hash-table (m 2)) (m 1))
		(loop (read-line)))))))))

(define (file-i-path dir)
  (build-path dir "plugins/file/file-i"))
(define (load-file-i file)
  (let1 hash-table (make-hash-table 'equal?)
    (with-input-from-file file
      (lambda ()
	(let loop ((l (read-line)))
	  (if (eof-object? l)
	      hash-table
	      (let1 m (#/^([^:]+): ([^\;]+)\; (.*)$/ l)
		(set! (ref hash-table (m 1)) (list (m 2) (m 3)))
		(loop (read-line)))))))))

;; /srv/sources/sources/r/ruby/1.8.6.399-5.fc14f
;; plugins/coreutils/wc

(define (wc-l-path dir)
  (build-path dir "plugins/coreutils/wc"))
(define (process-wc-l file md5sum file-i)
  (with-input-from-file file
      (lambda ()
	(let loop ((l (read-line)))
	  (unless (eof-object? l)
	    (let1 m (#/^ *(\d+) +(?:\d+) +(?:\d+) +(.*)$/ l)
	      (let1 line (string->number (m 1))
		(when (> line report-line-min)
		  (let1 file (m 2)
		    (write (list (ref md5sum file) file line (ref file-i file)))
		    (newline)))))
	    (loop (read-line)))))))

(define (main args)
  (let1 dir (cadr args)
    (process-wc-l (wc-l-path dir)
		  (load-md5sum (md5sum-path dir))
		  (load-file-i (file-i-path dir)))
    ))