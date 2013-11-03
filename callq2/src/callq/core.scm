(define-module callq.core
  (use callq.util)
  (use file.util)
  )
(select-module callq.core)

(debug-print-width #f)
(export-all)

(define-class <table> ()
  ((main-binary-file :init-value #f)
   (current-binary-file :init-value #f)
   (binary-files :init-form (make-hash-table 'equal?))
   (extras :init-form (make-hash-table 'eq?))
   ))

(define-class <callq-file> ()
  ((file-name :init-keyword :file-name)
   (entries :init-form (make-tree-map eq? <))
   ))
			  
(define-class <binary-file> (<callq-file>)
  (
   (source-files :init-form (make-hash-table 'equal?))
   (current-source-file :init-value #f)
   ))

(define-class <source-file> (<callq-file>)
  ((lines :init-form (make-tree-map eq? <))
   ))

;; (define-class <entry> ()
;;   ((address :init-keyword :address)
;;    (name :init-keyword :name)
;;    (source-file :init-keyword :source-file)
;;    (line :init-keyword :line)
;;    (binary-file :init-keyword :binary-file)
;;    (variable? :init-keyword :variable?)
;;    (entry-point :init-keyword :entry-point)))
;; (define-class <flow> ()
;;   ()
;;   )

;; (define-method add-entry! ((file <callq-file>)
;; 			   location
;; 			   (entry <entry>))
;;   (tree-map-put! (~ file 'entries) location entry))

;;
;; <table>
;;
(define-method current-binary-file ((table <table>))
  (~ table 'current-binary-file))
(define-method set-current-binary-file ((table <table>)
				   (file-name <string>))
  (let1 b (~ table 'binary-files file-name)
    (set! (~ table 'current-binary-file) b)))
  
(define-method add-binary-file! ((table <table>)
				 (file-name <string>)
				 (set-default? <boolean>))
  (let1 b (make <binary-file> :file-name file-name)
    (set! (~ table 'binary-files file-name) b)
    (when set-default?
      (set-current-binary-file table file-name))
    b))

(define-method set-main-binary-file ((table <table>)
				     (binary-file <binary-file>))
  (set! (~ table 'main-binary-file) 
	binary-file))
;;
;; <binary-file>
;;
(define-method current-source-file ((binary-file <binary-file>))
  (~ binary-file 'current-source-file))
(define-method set-current-source-file! ((binary-file <binary-file>)
					(file-name <string>))
  (let1 s (~ binary-file 'source-files file-name)
    (set! (~ binary-file 'current-source-file) s)))
(define-method ref-source-file ((binary-file <binary-file>)
				(file-name <string>))
  (ref (~ binary-file 'source-files) file-name #f))

(define-method add-source-file! ((binary-file <binary-file>)
				 (file-name <string>))
  (if-let1 s (ref-source-file binary-file file-name)
    s
    (let1 s (make <source-file> :file-name file-name)
      (set! (~ binary-file 'source-files file-name) s)
      s)))

(define-method add-line! ((source-file <source-file>)
			  (line <number>)
			  value)
  (set! (~ source-file 'lines line) value))

;;
;; Global state
;;
(define current-table
  (let1 table (make <table>)
    (^ () table)))

;;
;; Domain specific languages
;;
(define-macro (callp-begin
	       :key version input date)
  `(add-binary-file! ,(current-table) ,input #t))
(define-macro (readelf-so . rest)
  `(begin
     ,@(map
	(cute add-binary-file! (current-table) <> #f)
	rest)))

(define-macro (objdump-dcall subsel . args)
  (case subsel
    ('start-section
     (cons 'objdump-dcall-start-section args)
     )
    ('entry
     (cons 'objdump-dcall-entry args)
     )
    ('end-section
     (cons 'objdump-dcall-end-section args)
     )
    (else
     (errorf "unknown tag: ~a for objdump-dcall" subsel)
     )))

(define (objdump-dcall-context table slot :optional (default #f))
  (let1 extras (~ table 'extras)
    (let1 context (hash-table-get0 extras 
				   'objdump-dcall
				   (make-hash-table 'eq?))
      (~ context slot default))))

(define (objdump-dcall-context-set! table slot value)
  (let1 extras (~ table 'extras)
    (let1 context (hash-table-get0 extras
				   'objdump-dcall 
				   (make-hash-table 'eq?))
      (set! (~ context slot) value))))

(define-macro (objdump-dcall-start-section section)
  (objdump-dcall-context-set! (current-table) 'current-section section))

(define-macro (objdump-dcall-end-section section)
  )

(define-macro (objdump-dcall-entry addr name 
				   :key file line section 
				   connections objfile variable? 
				   entry-point)
  (let* ((b (current-binary-file (current-table)))
	 (s (if file (add-source-file! b file) #f))
	 (addr (string->number addr 16)))
    ;; TODO
    ;; flow
    (when (equal? name "main")
      (set-main-binary-file (current-table) b))
    #t))

(define-macro (libdwarves tag . args)
  (case tag
    ('compile_unit
     (cons 'libdwarves-compile-unit args))
    (else
     (cons* 'libdwarves-else tag args)
     )))

(define-macro (libdwarves-compile-unit :key
				       name language
				       filename supported)
  (define (rebuild-path binary-file-name source-file-name)
    ;; TODO
    ;; DIRTY!!!
    ;; Needs <compile-unit>
    (build-path (sys-dirname filename) name)
    )

  (let1 b (current-binary-file (current-table))
    (let1 spath (rebuild-path filename name)
      (add-source-file! b spath)
      (set-current-source-file! b spath))))

(define-macro (libdwarves-else tag . args)
  (let* ((file (kref args :file))
	 (line (kref args :line))
	 (b (current-binary-file (current-table)))
	 (s (current-source-file b)))
    (let1 s (cond
	     ((equal? file (~ s 'file-name)) s)
	     ((not file) #f)
	     (else (add-source-file! b file)))
      (when s
	(add-line! s line (cons tag args))))))

(define-macro (callp-end . args)
  )

(provide "callq/core")
