(defun profile ()
  (interactive)
  (require 'elp)
  (require 'time)
  (require 'cssize)
  (require 'xhtmlize)
  (require 'xhtmlize-engine)
  (require 'queue-m)
  (require 'shtmlize)
  (require 'shtmlize-engine)
  (require 'xhtmlize+linum-decl)
  (require 'xhtmlize+linum+fringe-decl)
  (require 'xhtmlize+linum-main)
  (require 'xhtmlize+linum+fringe-main)

  (let ((toggle-debug-on-quit t))
    (elp-reset-all)
    (elp-instrument-package "xhtmlize-")
    (elp-instrument-package "shtmlize-")
    (elp-instrument-package "mapcar")
    (elp-instrument-package "queue-p")
    (elp-instrument-package "queue-all")
    (time-expr '(shtmlize-file "/tmp/xdisp.c"))
    (elp-results)
    (elp-reset-all)))
    
  
(defun raw-profile ()
  (interactive)
  (elp-reset-all)
  (time-expr '(shtmlize-file "/tmp/xdisp.c")))
  
;; xhtmlize-file <IO>: 10
;; xhtmlize-engine-body-common: 24
;; - xhtmlize-width0-overlay: 7 <1>
;; -- xhtmlize-width0-overlay-acceptable-p: 2.39
;; -- xhtmlize-width0-overlay-render-direct: 3.28
;; - xhtmlize-overlays-at: 2
;; - xhtmlize-next-change: 4.38 <2>
;; - xhtmlize-faces-at-point: 3.4
;; - xhtmlize-buffer-substring-no-invisible: 1
;; - xhtmlize-trim-ellipsis: 0
;; - xhtmlize-untabify: 0.3
;; - shtmlize-enqueue-text-with-id: 7 <1>


