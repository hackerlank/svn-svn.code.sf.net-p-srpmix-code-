;;
;; scheme level utilities
;;
(define (pa$ proc . args)
  (lambda rest (apply proc (append args rest))))

;;
;; JS <-> Scheme interface
;;
(define (export var val)
  (js-field-set! *js* var val))

(define (run-hook hook)
  (for-each (lambda (proc) (proc)) hook))

;;
;; Yogomacs level
;;
;; (define find-file-pre-hook (list))
;; (export "run_find_file_pre_hook"
;; 	(lambda () (run-hook find-file-pre-hook)))
(define-hook find-file-pre-hook)

(define (load-lazy url params)
      (let ((options (js-new Object)))
	(set! options.method "get")
	(set! options.parameters params)
	(set! options.onFailure (lambda ()
				  (alert "An error occured")))
	(js-new Ajax.Updater
		"buffer"
		url
		options)))

