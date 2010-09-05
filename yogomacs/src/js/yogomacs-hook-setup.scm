(add-hook find-file-pre-hook focus)
(add-hook find-file-post-hook (pa$ jump-lazy (js-field (js-field *js* "location") "hash")))
(add-hook find-file-post-hook require-yarns)
