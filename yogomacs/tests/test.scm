#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(use gauche.test)
(use yogomacs.sanitize)

(define *test-report-error* #t)
(test-start "Yogomacs self test")
(test-module 'yogomacs.sanitize)

(test-section "sanitize")
(test* "/"
       "/" (sanitize-path "/"))

(test* "\"\""
       "/" (sanitize-path ""))

(test* "/a"
       "/a" (sanitize-path "/a"))

(test* "/a/.."
       "/" (sanitize-path "/a/.."))

(test* "/a/b/.."
       "/a" (sanitize-path "/a/b/.."))

(test* "/a/b/../"
       "/a" (sanitize-path "/a/b/../"))

(test* "/a/b/..//"
       "/a" (sanitize-path "/a/b/..//"))



(use yogomacs.check)
(test-module 'yogomacs.check)

(use yogomacs.params)
(test-module 'yogomacs.params)

(use yogomacs.html)
(test-module 'yogomacs.html)


(use yogomacs.cssize)
(test-module 'yogomacs.cssize)

(use yogomacs.dired)
(test-module 'yogomacs.dired)

(use yogomacs.emacsclient)
(test-module 'yogomacs.emacsclient)

(use yogomacs.flserver)
(test-module 'yogomacs.flserver)

(use yogomacs.font-lock)
(test-module 'yogomacs.font-lock)

(use yogomacs.yogomacs)
(test-module 'yogomacs.yogomacs)

(let ((v0 (test-end))
      (v1 (for-each (lambda ()) (list))))
  (if (eq? v0 v1)
      (exit 0)
      (exit v0)))