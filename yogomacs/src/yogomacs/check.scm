(define-module yogomacs.check
  (export 
   check-package
   check-file
   check-dir
   check-version
   check-stage
   check-file-display
   check-dir-display
   check-line
   check-range)
  (use srfi-1)
  (use srfi-13)
  (use file.util)
  (use yogomacs.config)
  )

(select-module yogomacs.check)


;; ---------------------------------------------------------------------
;;
;; Constants
;;
(define defined-stages  '(pre-build specs))
(define defined-file-displays '(raw font-lock))
(define defined-dir-displays '(raw font-lock))


;; ---------------------------------------------------------------------
;;
;; Parameter Checkers
;;
(define (check-package package err-return)
  (unless (string? package)
    (err-return "No package"))
  (unless (> (string-length package) 0)
    (err-return "No package"))
  (when (or (equal? package ".")
	    (equal? package "..")
	    (string-index package #\/))
    (err-return "No package"))
  package)

(define (check-file file err-return)
  (when (string-scan file "..")
    (err-return "Broken file"))
  (when (string-scan file ".htaccess")
    (err-return "Broken file"))
  file)

(define (check-dir dir err-return)
  (let1 path (simplify-path (build-path prefix dir))
    (unless (string-prefix? prefix path)
      (err-return "Broken dir"))
    path))

(define (check-version version err-return)
  (when (string-scan version "/")
    (err-return "Broken version"))
  (when (string-scan version "..")
    (err-return "Broken version"))
  version)

(define (check-stage stage err-return)
  (unless (member (string->symbol stage) defined-stages)
    (err-return (format "Undefined stage: ~s" stage)))
  stage)

(define (check-display display all err-return)
  (unless (member (string->symbol display) all)
    (err-return (format "Undefined display: ~s" display)))
  (string->symbol display))

(define (check-file-display display err-return)
  (check-display display defined-file-displays err-return))
(define (check-dir-display display err-return)
  (check-display display defined-dir-displays err-return))

(define (check-line line err-return)
  (if (string? line)
      (let1 b  (string->number line)
	(unless (and b (integer? b) (< 0 b))
	  (err-return (format "Broken line format: ~s" line)))
	b)
      line))

(define (check-range range err-return)
  (if range
      (let1 splited (string-split range #/-/)
	(unless (and (list? splited) 
		     (eq? (length splited) 2))
	  (err-return (format "Broken range format: ~s" range)))
	(let ((start (check-line (car splited)  err-return))
	      (end   (check-line (cadr splited) err-return)))
	  (unless (< start end)
	    (err-return (format "Broken range format: ~s" range)))
	  (list-tabulate (- end start) (lambda (i) (+ start i))) ))
      range))

(provide "yogomacs/check")
