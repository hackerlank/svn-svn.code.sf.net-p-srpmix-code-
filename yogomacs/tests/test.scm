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
 yogomacs.rearranges.yogomacs-fragment
 yogomacs.dests.root-dir
 yogomacs.dests.root-plugins-dir
 yogomacs.dests.srpmix-dir
 yogomacs.dests.css
 yogomacs.dests.js
 yogomacs.dests.sources-dir
 yogomacs.dests.dists-dir
 yogomacs.dests.packages-dir
 yogomacs.dests.fs
 yogomacs.dests.pkg-dir
 yogomacs.dests.dir
 yogomacs.dests.debug
 yogomacs.dests.print-alist
 yogomacs.dests.file
 yogomacs.dests.text
 yogomacs.dests.ysh-dir
 yogomacs.error
 yogomacs.dentry
 yogomacs.compress
 yogomacs.dentries.fs
 yogomacs.dentries.text
 yogomacs.dentries.virtual
 yogomacs.dentries.redirect
 yogomacs.cache
 yogomacs.face
 yogomacs.main
 yogomacs.renderers.asis
 yogomacs.renderers.find-file
 yogomacs.renderers.fundamental
 yogomacs.renderers.cache
 yogomacs.renderers.dired
 yogomacs.renderers.syntax
 yogomacs.renderers.yogomacs
 yogomacs.reply
 yogomacs.batch
 yogomacs.access
 yogomacs.sanitize
 yogomacs.path
 yogomacs.route
 yogomacs.config
;; yogomacs.caches.check
 yogomacs.caches.css
 yogomacs.caches.js
 yogomacs.caches.shtml
 yogomacs.flserver
 yogomacs.shell
 yogomacs.window
 yogomacs.entry
 yogomacs.renderers.ewoc
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
       #f (fundamental "./foo.c" #f #f ()))

(use yogomacs.config)
(define config-proc0 (config->proc '((key0 . "value0"))))
(define config-proc1 ((config-proc0 'key0 "value-1") 'key1 "value1"))
(test* "config proc"
       "value0"
       (config-proc0 'key0))
(test* "config proc"
       "value-1"
       (config-proc1 'key0))
(test* "config proc"
       "value1"
       (config-proc1 'key1))

(exit (if (zero? (test-end)) 0 1))
