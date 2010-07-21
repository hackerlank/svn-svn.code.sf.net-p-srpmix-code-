#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

(use gauche.test)
(use yogomacs.sanitize)

(define *test-report-error* #t)
(test-start "Yogomacs self test")

(test-section "bindings")
(define-macro (use-and-test-module m)
  `(begin
     (use ,m)
     (test-module (quote ,m))))
(define-macro (for-each-use-and-test-module . modules)
  `(begin
     ,@(map (lambda (m) (list 'use-and-test-module m)) modules)))

(for-each-use-and-test-module
;; find -name '*.scm' -type f | sed -e's|\./|/|' -e 's|\.scm||' -e 's|.*|yogomacs\0|' -e 's|/|.|g' | grep -v default  
 yogomacs.rearranges.css-href
 yogomacs.rearranges.face-integrates
 yogomacs.rearranges.css-integrates
 yogomacs.dests.root-dir
 yogomacs.dests.srpmix-dir
 yogomacs.dests.css
 yogomacs.dests.sources-dir
 yogomacs.dests.fs
 yogomacs.dests.pkg-dir
 yogomacs.dests.dir
 yogomacs.dests.debug
 yogomacs.dests.print-alist
 yogomacs.dests.file
 yogomacs.error
 yogomacs.dentry
 yogomacs.compress
 yogomacs.dentries.fs
 yogomacs.cache
 yogomacs.face
 yogomacs.main
 yogomacs.renderers.asis
 yogomacs.renderers.find-file
 yogomacs.renderers.fundamental
 yogomacs.renderers.cache
 yogomacs.renderers.dired
 yogomacs.renderers.syntax
 yogomacs.reply
 yogomacs.batch
 yogomacs.access
 yogomacs.sanitize
 yogomacs.path
 yogomacs.route
 yogomacs.config
;; yogomacs.caches.check
 yogomacs.caches.css
 yogomacs.caches.shtml
 yogomacs.flserver
)







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

(use yogomacs.access)
(test* "/etc/passwd"
       "/etc/passwd" (readable? "/etc" "passwd"))
(test* "/var/log/messages"
       #f (readable? "/var/log" "messages"))

(test* "fundamental foo.c"
       #f (fundamental "./foo.c" #f ()))

(exit (if (zero? (test-end)) 0 1))
