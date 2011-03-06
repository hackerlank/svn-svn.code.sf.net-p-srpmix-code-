(define-module outlang.outlang
  (export outlang)
  (use outlang.htmlprag)
  (use gauche.process)
  )
(select-module outlang.outlang)

(define prefix "/usr")
(define dir "/share/outlang/")

(debug-print-width #f)

(define (outlang source-file)
  (let* ((proc (run-process
		`(source-highlight 
		  --tab=8
		  --doc
		  ,#`"--outlang-def=,|prefix|,|dir|yogomacs.outlang"
		  --infer-lang 
		  ,#`"--input=,|source-file|"
		  "--output=STDOUT")
		:output :pipe))
	 (output (process-output proc)))
    (let1 shtml (guard (e (else #f)) (html->shtml output))
      (let1 r (cond
	       ((not shtml) #f)
	       ((equal? shtml '(*TOP*)) #f)
	       (else
		shtml))
	;; TODO: Nohung
	(process-wait proc)
	(if (eq? (process-exit-status proc) 0)
	    r
	    #f)))))

(provide "outlang/outlang")
