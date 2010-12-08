(add-hook find-file-pre-hook focus)
(add-hook find-file-post-hook (pa$ jump-lazy (js-field (js-field *js* "location") "hash")))
(add-hook find-file-post-hook require-yarns)

(define exp-dnd 
  (lambda ()
    (js-new Draggable "minibuffer-prompt" (alist->object 
					   `((ghosting . #f)
					     (revert . #t)
					     (onStart . ,(lambda (draggable event)
							   (let1 prompt ($ "minibuffer-prompt")
							     (js-field-set! draggable
									    "original"
									    (js-field prompt "innerHTML"))
							     (prompt.update (<- "minibuffer")))))
					     (onEnd . ,(lambda (draggable event)
							 (let1 prompt ($ "minibuffer-prompt")
							   (prompt.update  (js-field draggable 
										     "original"))))))))
    (let1 options (alist->object 
		   `(
		     (onDrop . ,(lambda (draggable droppable event)
				  (let* ((id (js-field droppable "id"))
					 ;; l/N:.
					 ;; l/P:1/L:1
					 (target (if (eq? (string-ref id 2) #\N)
						     `(directory ,(car (reverse 
									(string-split id
										      ":"))))
						     `(file ,(string->number 
							      (car (reverse 
								    (string-split id
										  ":")))))))
					 (content `(text ,(<- "minibuffer")))
					 (date #f)
					 (full-name "Masatake YAMATO")
					 (mailing-address "yamato@redhat.com")
					 (subjects '("from-minibuffer"))
					 (transited #f))
				    (let1 prompt ($ "minibuffer-prompt")
				      (prompt.update  (js-field draggable 
								"original")))
				    (stitch-yarn `(yarn :target ,target
							:content ,content
							:date ,date
							:full-name ,full-name
							:mailing-address ,mailing-address
							:subjects ,subjects
							:transited ,transited))
				    )))
		     ))
      (($$ ".lfringe").each (lambda (id) (Droppables.add 
					  (js-field id "id")
					  options)))
      )))
;(add-hook find-file-post-hook exp-dnd)
;(add-hook lfringe-hook stitch-popup-lfringe-menu)
;(add-hook rfringe-hook (lambda (rfringe type) (alert type)))
(add-hook draft-box-abort-hook stitch-delete-draft-box)