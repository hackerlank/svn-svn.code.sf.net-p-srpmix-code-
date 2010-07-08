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

(use yogomacs.fix)
(test-module 'yogomacs.fix)
(use yogomacs.dests.root-dir)
(test-module 'yogomacs.dests.root-dir)
(use yogomacs.dests.srpmix-dir)
(test-module 'yogomacs.dests.srpmix-dir)
(use yogomacs.dests.css)
(test-module 'yogomacs.dests.css)
(use yogomacs.dests.sources-dir)
(test-module 'yogomacs.dests.sources-dir)
(use yogomacs.dests.pkg-dir)
(test-module 'yogomacs.dests.pkg-dir)
(use yogomacs.dests.dir)
(test-module 'yogomacs.dests.dir)
(use yogomacs.dests.fs)
(test-module 'yogomacs.dests.fs)
(use yogomacs.dests.file)
(test-module 'yogomacs.dests.file)
(use yogomacs.dests.debug)
(test-module 'yogomacs.dests.debug)
(use yogomacs.dests.print-alist)
(test-module 'yogomacs.dests.print-alist)
(use yogomacs.dentry)
(test-module 'yogomacs.dentry)
;(use yogomacs.compress)
;(test-module 'yogomacs.compress)
(use yogomacs.dentries.fs)
(test-module 'yogomacs.dentries.fs)
(use yogomacs.main)
(test-module 'yogomacs.main)
(use yogomacs.renderers.cache)
(test-module 'yogomacs.renderers.cache)
(use yogomacs.renderers.dired)
(test-module 'yogomacs.renderers.dired)
(use yogomacs.renderers.find-file)
(test-module 'yogomacs.renderers.find-file)
(use yogomacs.access)
(test-module 'yogomacs.access)

(use yogomacs.caches.css)
(test-module 'yogomacs.caches.css)
(use yogomacs.sanitize)
(test-module 'yogomacs.sanitize)
(use yogomacs.path)
(test-module 'yogomacs.path)
(use yogomacs.route)
(test-module 'yogomacs.route)
(use yogomacs.config)
(test-module 'yogomacs.config)
(use yogomacs.flserver)
(test-module 'yogomacs.flserver)
(use yogomacs.gzip)
(test-module 'yogomacs.gzip)

(test* "/etc/passwd"
       "/etc/passwd" (readable? "/etc" "passwd"))
(test* "/var/log/messages"
       #f (readable? "/var/log" "messages"))

(exit (if (zero? (test-end)) 0 1))
