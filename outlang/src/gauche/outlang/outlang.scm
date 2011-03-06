(define-module outlang.outlang
  (export outlang)
  (use outlang.htmlprag)
  )
(select-module outlang.outlang)

(define prefix "/usr")
(define dir "/share/outlang/")

(debug-print-width #f)

(define (outlang source-file)
  (receive (port fname) (sys-mkstemp "/tmp/OUTLANG")
    (let1 proc (run-process
		`(source-highlight 
		  --tab=8
		  --doc
		  ,#`"--outlang-def=,|prefix|,|dir|yogomacs.outlang"
		  --infer-lang 
		  ,#`"--input=,|source-file|"
		  ,#`"--output=,|fname|"
		  )
		:wait #t)
      (if (eq? (process-exit-status proc) 0)
	  (let1 shtml (call-with-input-file fname html->shtml)
	    (sys-unlink fname)
	    (if (equal? shtml '(*TOP*))
		#f
		shtml))))))

(provide "outlang/outlang")
