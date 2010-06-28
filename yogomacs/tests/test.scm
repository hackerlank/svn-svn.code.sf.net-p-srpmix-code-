#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(use gauche.test)
(use yogomacs.sanitize)

(define *test-report-error* #t)
(test-start "Yogomacs self test")
(test-module 'yogomacs.sanitize)

(test-section "sanitize")

(test* "a"
       "/" (sanitize-path "a"))

(test* "/"
       "/" (sanitize-path "/"))
(test* "//"
       "/" (sanitize-path "//"))
(test* "///"
       "/" (sanitize-path "///"))
(test* "///a"
       "/a" (sanitize-path "///a"))
(test* "///a/"
       "/a" (sanitize-path "///a/"))
(test* "///a//"
       "/a" (sanitize-path "///a//"))
(test* "///a//b"
       "/a/b" (sanitize-path "///a//b"))
(test* "///a//b/"
       "/a/b" (sanitize-path "///a//b/"))
(test* "///a//b/.."
       "/a" (sanitize-path "///a//b/.."))
(test* "///a//b/../"
       "/a" (sanitize-path "///a//b/../"))
(test* "///a//b/..//"
       "/a" (sanitize-path "///a//b/..//"))

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

(test* "/a/"
       "/a" (sanitize-path "/a/"))

(test* "/a/."
       "/a" (sanitize-path "/a/."))

(test* "/.."
       "/" (sanitize-path "/.."))

(test* "/../a"
       "/a" (sanitize-path "/../a"))
(test* "/../a/"
       "/a" (sanitize-path "/../a/"))
(test* "/a/.."
       "/" (sanitize-path "/a/.."))
(test* "/a/../"
       "/" (sanitize-path "/a/../"))

(test* "/../"
       "/" (sanitize-path "/../"))

(use yogomacs.main)
(test-module 'yogomacs.main)

(use yogomacs.dentry)
(test-module 'yogomacs.dentry)

(use yogomacs.dired)
(test-module 'yogomacs.dired)

(use yogomacs.route)
(test-module 'yogomacs.route)

(use yogomacs.dentries.fs)
(test-module 'yogomacs.dentries.fs)

(use yogomacs.handlers.deliver-css)
(test-module 'yogomacs.handlers.deliver-css)

(use yogomacs.handlers.print-alist)
(test-module 'yogomacs.handlers.print-alist)

(use yogomacs.handlers.root-dir)
(test-module 'yogomacs.handlers.root-dir)

(use yogomacs.access)
(test-module 'yogomacs.access)

(test* "/etc/passwd"
       "/etc/passwd" (readable? "/etc" "passwd"))
(test* "/etc/passwd-"
       #f (readable? "/etc" "passwd-"))

(exit (if (zero? (test-end)) 0 1))
