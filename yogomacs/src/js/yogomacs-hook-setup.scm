(add-hook find-file-pre-hook focus)
(add-hook find-file-post-hook (pa$ jump-lazy (js-field (js-field *js* "location") "hash")))
(add-hook find-file-post-hook require-yarns)
(add-hook find-file-post-hook 
	  (lambda ()
	    (let1 spared-prompt #f
	      (let1 options (alist->object 
			     `((ghosting . #f)
			       (revert . #t)
			       (onStart . ,(lambda (draggable event)
					     (let ((prompt ($ "minibuffer-prompt"))
						   (text (<- "minibuffer")))
					       (js-field-set! draggable
							      "original-prompt-text"
							      prompt.innerHTML)
					       (set! spared-prompt prompt)
					       (js-field-set! draggable
							      "prompt"
							      prompt)
					       (js-field-set! draggable
							      "text"
							      text)
					       (prompt.update text))))
			       (onEnd . ,(lambda (draggable event)
					   (let1 prompt ($ "minibuffer-prompt")
					     (prompt.removeClassName "highlight")
					     (prompt.update  (js-field draggable 
								       "original-prompt-text")))))))
		(js-new Draggable "minibuffer-prompt" options))
	      (let1 options (alist->object 
			     `(
			       ;; (yarn :target X :content X :date X :full-name :mailing-address :subjects :transited #f)
			       ;; target: file, directory
			       ;; cond
			       (onDrop . ,(lambda (draggable droppable event)
					    (let* ((id (js-field droppable "id"))
						   ;; l/N:.
						   ;; l/P:1/L:1
						   (target (if (eq? (string-ref id 2) #\N)
							       `(directory ,(car (reverse (string-split id ":"))))
							       `(file ,(string->number 
									(car (reverse (string-split id ":")))))))
						   (content `(text ,(<- "minibuffer")))
						   (date (let1 d (js-new Date)
							   (string-append
							    (d.getFullYear) "-" (+ (d.getMonth) 1) "-" (d.getDate))
							   ))
						   (full-name "Masatake YAMATO")
						   (mailing-address "yamato@redhat.com")
						   (subjects '("from-minibuffer"))
						   (transited #f)
						   (d `(yarn :target ,target
							     :content ,content
							     :date ,date
							     :full-name ,full-name
							     :mailing-address ,mailing-address
							     :subjects ,subjects
							     :transited ,transited)))
					      (let1 prompt ($ "minibuffer-prompt")
						(prompt.removeClassName "highlight")
						(prompt.update  (js-field draggable 
									  "original-prompt-text")))
					      (stitch-yarn d)
					      )))
			       ))
		(($$ ".lfringe").each (lambda (id) (Droppables.add id.id options)))
		))))