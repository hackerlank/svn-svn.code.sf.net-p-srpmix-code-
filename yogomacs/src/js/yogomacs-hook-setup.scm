(add-hook find-file-pre-hook focus)
(add-hook find-file-pre-hook header-line-init)
(add-hook find-file-post-hook (lambda any (jump-lazy (js-field (js-field *js* "location") "hash"))))
(add-hook find-file-post-hook major-mode-init)
(add-hook find-file-post-hook tag-init)
(add-hook find-file-post-hook require-yarn)
(add-hook draft-box-abort-hook stitch-delete-draft-box)
(add-hook draft-box-submit-hook stitch-submit)