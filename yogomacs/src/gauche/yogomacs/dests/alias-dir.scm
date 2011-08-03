(define-module yogomacs.dests.alias-dir
  (export alias-dir-dest)
  (use yogomacs.dests.srpmix-dir))

(select-module yogomacs.dests.alias-dir)

(define alias-dir-dest (srpmix-dir-make-dest
			"^/sources/[a-zA-Z0-9]/[^/]+/\^alias-[^/]+"))

(provide "yogomacs/dests/alias-dir")