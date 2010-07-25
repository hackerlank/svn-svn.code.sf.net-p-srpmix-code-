(define-module yogomacs.renderers.text
  (export text
	  lines)
  (use yogomacs.access)
  (use yogomacs.error)
  (use srfi-19)
  (use srfi-13)
  (use srfi-1)
  (use util.combinations))
(select-module yogomacs.renderers.text)

(define (stylesheet face title)
  `("\t" 
    (link (|@| 
	   (rel "stylesheet") 
	   (type "text/css")
	   (href ,#`"file:///tmp/,|face|--,|title|.css") (title ,title)))
    "\n"))

(define (lines0 src-path config lines mtime)
  (let* ((max-lines (length lines))
	 (width (+ (floor->exact (log max-lines 10))
		   1))
	 (fmt (string-append "~" (number->string width) ",d")))
    `(*TOP*
      (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"") "\n"
      (*DECL* DOCTYPE html PUBLIC 
	      "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd") "\n"
	      (html (|@| (xmlns "http://www.w3.org/1999/xhtml")) "\n"
		    (head "\n" 
			  "\t" (title ,src-path) "\n" 
			  "\t" (meta (|@|
				      (name "major-mode") 
				      (content "fundamental-mode"))) "\n"
			  "\t" (meta (|@| 
				      (name "created-time")
				      (content ,(date->string (time-utc->date (make-time 'time-utc 0 mtime))
							      "~5")))) "\n" 
			  "\t" (meta (|@| 
				      (name "version")
				      (content "0.0.0"))) "\n"
			  "\t" (meta (|@| 
				      (name "point-max")
				      (content ,(+ (length lines) 
						   (reduce +
							   0
							   (map string-length lines))
						   )))) "\n" 
			  "\t" (meta (|@| 
				      (name "count-lines")
				      (content ,max-lines))) "\n"
			  ,@(apply append 
				   (map (lambda (face-style)
					  (stylesheet (car face-style) (cadr face-style)))
					(cartesian-product '(("default"
							     "highlight"
							     "lfringe"
							     "linum"
							     "rfringe")
							     ("Default" 
							      "Invert"))))) "\n"
							      ) "\n"
			    (body "\n"
				  (pre "\n"
				       ,@(apply append 
						(reverse 
						 (car
						  (fold (lambda (kar kdr)
							  (let ((shtml (ref kdr 0))
								(line (ref kdr 1))
								(char (ref kdr 2)))
							    (list 
							     (cons 
							      `((span (|@| 
								       (class "linum")
								       (id ,#`"L:,|line|"))
								      (a (|@| 
									  (href ,#`"#L:,|line|")) 
									 ,(format fmt line)))
								(span (|@| 
								       (class "lfringe") 
								       (id ,#`"l/P:,|char|/L:,|line|"))
								      " ")
								(span (|@| 
								       (class "rfringe")
								       (id ,#`"r/L:,|line|"))
								      " ")
								,(string-append kar "\n")) shtml)
							     (+ line 1)
							     (+ char (string-length kar)))))
							(list (list) 1 1)
							lines))))
				       ) "\n"
					 ) "\n" 
					   ) "\n" 
					     )))

(define (lines src-path config data mtime)
   (values (lines0 src-path config data mtime)
	   mtime))

(define (text src-path config data mtime)
   (values (lines0 src-path config (string-split data #\newline) mtime)
	   mtime))

(provide "yogomacs/renderers/text")