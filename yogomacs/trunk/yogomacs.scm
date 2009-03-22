#|
<div class="default" id="bs-console"></div>
<script src="file:///home/jet/workspace/biwascheme/lib/biwascheme.js">
(load "file:///home/jet/workspace/srpmix/yogomacs/trunk/yogomacs.scm")
</script>
|#
;;
;; Utilities
;;
(define (error msg)
  (let1 code (string-append "throw new Error(\"yogomacs: " 
			   msg
			   "\");")
    (js-eval code)))

;; biwascheme doesn't have format
(define (message msg)
  (display (string-append msg "\n")))


(define (current-buffer) (js-eval "document"))

(define (elements-of-class-of pat) 
  (let1 code (string-append "$$('" pat "').to_list();")
    (js-eval code)))

;;
;; Initializer
;;
(define yogomacs-initialized? #f)
(define (init-yogomacs)
  (unless yogomacs-initialized?
    (set! yogomacs-initialized? #t)
    (let1 document (js-eval "document")
      (add-handler! document "keypress" dispatch-event))
    
    (linum-mode #t)
    (display "")
    ))

;;		    
;; Keymap
;;
(define (make-keymap name) 
  (list 'keymap name  (list)))

(define (keymap? keymap) 
  (and
   (list? keymap)
   (not (null? keymap))
   (eq? (car keymap) 'keymap)))

(define (lookup-key keymap key)
  (unless (keymap? keymap)
    (error (string-append "lookup-key: broken KEYMAP")))
  (let1 r (assoc key (caddr keymap))
    (if r
	(cdr r)
	#f)))

(define (define-key kmap kseq proc)
  (unless (keymap? kmap)
    (error (string-append "define-key: broken KEYMAP")))
  (unless (list? kseq)
    (error (string-append "define-key: broken kseq")))
  (when (null? kseq)
    (error (string-append "define-key: KSEQ is empty")))
  (define-key0 kmap (car kseq) (cdr kseq) proc))

(define (define-key0 kmap key rest proc)
  (let1 key (if (list? key) key (list key))
    (if (null? rest)
	(let1 slot (assoc key (caddr kmap))
	  (if slot
	      (set-cdr! slot proc)
	      (set-car! (cddr kmap)
			(cons
			 (cons key proc)
			 (caddr kmap)))))
	(let1 submap (make-keymap #f)
	  (define-key0 kmap key (list) submap)
	  (define-key0 submap (car rest) (cdr rest) proc)))))

(define global-map (make-keymap "global-map"))


;;
;; Event
;;
(let ((current-state-map global-map))
  (define (dispatch-event e)
    (define (update-current-state-map! map)
      (set! current-state-map map))
    (dispatch-event0 e 
		     current-state-map
		     update-current-state-map!)))

(define (dispatch-event0 e root-map update-map!)
  ;; http://js.halaurum.googlepages.com/sample_key_event.html
  ;; C-M-x
  (let ((charCode->char (lambda (charCode)
			  (integer->char charCode)))
	(keydown-event-ref (lambda (event slot)
			     (js-ref event (symbol->string slot)))))
    (let* ((c (charCode->char (keydown-event-ref e 'charCode)))
	   (M (keydown-event-ref e 'altKey))
	   (C (keydown-event-ref e 'ctrlKey))
	   (keyseq (list c)))
      (when M
	(set! keyseq (cons 'M keyseq)))
      (when C
	(set! keyseq (cons 'C keyseq)))
      (let1 r (lookup-key root-map keyseq)
	(cond
	 ((keymap? r)
	  (update-map! r))
	 ((not r)
	  (update-map! global-map)
	  (error "dispatch-event0: keyseq is undefined"))
	 (else
	  (let1 r0 (apply r (make-interactive-args r))
	    (update-map! global-map)
	    r0)))))))

;; 
;; Interactive-Spec
;;
(define-macro (define-interactive proc-sign interactive-spec body)
  `(begin
     (define ,proc-sign ,@body)
     (define-interactive-spec ,(car proc-sign) ',interactive-spec)))

(let ((prefix #f)
      (interactive-spec-table (list)))
  (define (define-interactive-spec proc interactive-spec)
    (let1 cell (assoc proc interactive-spec-table)
      (if cell
	  (set-cdr! cell interactive-spec)
	  (set! interactive-spec-table (cons (cons proc 
						   interactive-spec)
					     interactive-spec-table)))))
  (define (make-interactive-args proc)
    (let1 cell (assoc proc interactive-spec-table)
      (let1 r (if cell
		  (map (lambda (s) 
			 (cond
			  ((equal? s "P") prefix)
			  (else #f))
			 )
		       (cdr cell))
		  (list))
	(set! prefix #f)
	r)))

  (define-interactive (universal-argument) ()
    (
     (set! prefix #t)
     )))

(define-interactive (linum-mode p) ("P")
  (
   ;;
   (let1 linums (elements-of-class-of ".linum")
     (if p
	 (for-each (lambda(l) 
		     (element-update! l "")
		     ) linums)
	 (let* ((id-prefix     "linum:")
		(id-prefix-len (string-length id-prefix))
		(max-len (- (string-length 
			     (element-read-attribute 
			      (car (reverse linums))
			      "id"))
			    id-prefix-len))
		(pad-str-len 0)
		(pad-str #f))
	   (for-each (lambda (l) 
		       (let* ((id (element-read-attribute l "id"))
			      (id-len (string-length id))
			      (line-str (substring id id-prefix-len id-len))
			      (local-pad-len (- max-len (- id-len id-prefix-len))))
			 (when (not (eq? pad-str-len local-pad-len))
			       (set! pad-str-len local-pad-len)
			       (set! pad-str (make-string pad-str-len #\space)))
			 (element-update! l (string-append pad-str line-str " "))))
		     linums))))
   ;;
   ))


(define-key global-map '(#\t) linum-mode)
(define-key global-map '(#\u) universal-argument)
;(define-key global-map '((#\<)) linum-mode)
;(define-key global-map '((#\>)) linum-mode)

(init-yogomacs)

;; format procedure? let-loop
