(define-module yogomacs.renderers.fundamental
  (export fundamental)
  (use yogomacs.access)
  (use yogomacs.error)
  (use srfi-19)
  (use srfi-1))
(select-module yogomacs.renderers.fundamental)

(define (yogomacs-shtml src-path mtime lines)
  `(*TOP*
    (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"") "\n"
    (*DECL* DOCTYPE html PUBLIC 
	    "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd") "\n"
    (html (|@| (xmlns "http://www.w3.org/1999/xhtml")) "\n"
	  (head "\n" 
		"\t" (title ,src-path) "\n" 
		"\t" (meta (|@| (name "major-mode") (content "fundamental-mode"))) "\n"
		"\t" (meta (|@| (name "created-time") (content ,(date->string (time-utc->date (make-time 'time-utc 0 mtime))
									      "~5")))) "\n" 
		"\t" (meta (|@| (name "version") (content "0.0.0"))) "\n"
		"\t" (meta (|@| (name "point-max") (content ,(+ (length lines) 
								(reduce +
									0
									(map string-length lines))
								)))) "\n" 
		"\t" (meta (|@| (name "count-lines") (content ,(length lines)))) "\n"
		"\t" (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/default--Default.css") (title "Default"))) "\n"
		"\t" (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/highlight--Default.css") (title "Default"))) "\n"
		"\t" (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/lfringe--Default.css") (title "Default"))) "\n"
		"\t" (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/linum--Default.css") (title "Default"))) "\n"
		"\t" (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/rfringe--Default.css") (title "Default"))) "\n"
		"\t" (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/default--Invert.css") (title "Invert"))) "\n"
		"\t" (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/highlight--Invert.css") (title "Invert"))) "\n"
		"\t" (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/lfringe--Invert.css") (title "Invert"))) "\n"
		"\t" (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/linum--Invert.css") (title "Invert"))) "\n"
		"\t" (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/rfringe--Invert.css") (title "Invert"))) "\n"
		) "\n"
	  (body "\n"
		(pre "\n"
		     ,@(apply append (reverse (car (fold (lambda (kar kdr)
							    (let ((shtml (ref kdr 0))
								  (line (ref kdr 1))
								  (char (ref kdr 2)))
							       (list 
								(cons 
								 `((span (|@| (class "linum") (id ,#`"L:,|line|"))
									 (a (|@| (href ,#`"#L:,|line|")) ,#`",|line|"))
								   (span (|@| (class "lfringe") (id ,#`"l/P:,|char|/L:,|line|")) " ")
								   (span (|@| (class "rfringe") (id ,#`"r/L:,|line|")) " ")
								   ,(string-append kar "\n")) shtml)
								(+ line 1)
								(+ char (string-length kar)))))
							 (list (list) 1 1)
							 lines))))
		     ) "\n"
		       ) "\n" 
			 ) "\n" 
			   ))


(define (fundamental src-path config)
  (if (readable? src-path)
      (let1 t (ref (sys-stat src-path) 'mtime)
	(values (yogomacs-shtml src-path 
				t
				(call-with-input-file src-path
				  port->string-list
				  :if-does-not-exist :error
				  :element-type :character))
		t))
      (not-found "File not found"
		 src-path)))

(provide "yogomacs/renderers/fundamental")