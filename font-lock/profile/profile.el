(require 'time)

(defun profile ()
  (interactive)
  (elp-reset-all)
  (elp-instrument-package "xhtmlize-")
  (elp-instrument-package "shtmlize-")
  (time-expr '(shtmlize-file "/tmp/xdisp.c"))
  (elp-results))
  