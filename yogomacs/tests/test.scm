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
yogomacs.rearranges.enum
yogomacs.rearranges.range
yogomacs.rearranges.yogomacs-fragment
yogomacs.rearranges.css-href
yogomacs.rearranges.face-integrates
yogomacs.rearranges.eof-line
yogomacs.rearranges.title
yogomacs.rearranges.checkout
yogomacs.rearranges.line-trim
yogomacs.rearranges.css-integrates
yogomacs.commands.checkout
yogomacs.shells.bscm
yogomacs.shells.ysh
yogomacs.shells.nologin
yogomacs.domain
yogomacs.dests.lcopy-dir
yogomacs.dests.login
yogomacs.dests.root-dir
yogomacs.dests.absentees-dir
yogomacs.dests.srpmix-dir
yogomacs.dests.js
yogomacs.dests.annotations-dir
yogomacs.dests.dists-dir
yogomacs.dests.css
yogomacs.dests.packages-dir
yogomacs.dests.sources-dir
yogomacs.dests.fs
yogomacs.dests.pkg-dir
yogomacs.dests.ysh-dir
yogomacs.dests.yarn
yogomacs.dests.text
yogomacs.dests.dir
yogomacs.dests.root-commands-dir
yogomacs.dests.debug
yogomacs.dests.print-alist
yogomacs.dests.bscm-dir
yogomacs.dests.subjects
yogomacs.dests.file
yogomacs.error
yogomacs.dentry
yogomacs.window
yogomacs.dentries.virtual
yogomacs.dentries.subject
yogomacs.dentries.fs
yogomacs.dentries.text
yogomacs.dentries.redirect
yogomacs.reels.stitch-es
yogomacs.role
yogomacs.shells
yogomacs.cache
yogomacs.face
yogomacs.reel
yogomacs.main
yogomacs.renderers.asis
yogomacs.renderers.find-file
yogomacs.renderers.cache
yogomacs.renderers.archive
yogomacs.renderers.dired
yogomacs.renderers.text
yogomacs.renderers.fundamental
yogomacs.renderers.syntax
yogomacs.renderers.ewoc
yogomacs.renderers.yogomacs
yogomacs.entry
yogomacs.shell
yogomacs.reply
yogomacs.util.enum
yogomacs.util.range
yogomacs.util.compress
yogomacs.util.lcopy
yogomacs.util.scheme2js
yogomacs.util.ebuf
yogomacs.batch
yogomacs.access
yogomacs.yarn
yogomacs.storages.js
yogomacs.storages.css
yogomacs.storages.yarn
yogomacs.params
yogomacs.sanitize
yogomacs.path
yogomacs.auth
yogomacs.route
yogomacs.config
yogomacs.caches.shtml
yogomacs.command
yogomacs.user
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


(use yogomacs.domain)
(define (srv-sources key) "/srv/sources")
(test* "in-domain? #t"
       #t
       (in-domain? "/srv/sources/sources/k/kernel/2.6.9-78.EL/specs.spec"
		   srv-sources
		   ))

(test* "in-domain? non-slash"
       #f
       (in-domain? "srv/sources/sources/k/kernel/2.6.9-78.EL/specs.spec"
		   srv-sources
		   ))
(test* "in-domain? non-slash"
       #f
       (in-domain? ""
		   srv-sources
		   ))

(define (srv-sources+domains key) 
  (if (eq? key 'real-sources-dir)
      "/srv/sources"
      '("/srv/sources"
	"/net/sources/srv/sources"
	"/net/sop/srv/sources")))

(test* "to-domain? "
       #t
       (to-domain? "/srv/sources/sources/k/kernel/2.6.9-78.EL/specs.spec"
		   srv-sources+domains
		   ))

(use yogomacs.util.lcopy)
(test* "lcopy kernel trunk"
       "git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git "
       (lcopy-dir->checkout-cmdline "/srv/sources/sources/k/kernel/^lcopy-trunk"))

(use yogomacs.path)
(test* "directory-file-name1"
       "/a/b"
       (directory-file-name "/a/b/"))
(test* "directory-file-name2"
       "/a/b"
       (directory-file-name "/a/b"))

(test* "directory-file-name3"
       "/"
       (directory-file-name "/"))

(exit (if (zero? (test-end)) 0 1))
