#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

;; > STDIN
;;  (srpmix-wrap  ... :package PACKAGE ... :wrapped-name WRAPPED-NAME ...)
;;  (srpmix-group name [desc])

(use util.match)


(define (print-header)
  (map print 
       '("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	 "<!DOCTYPE comps PUBLIC \"-//Red Hat, Inc.//DTD Comps info//EN\" \"comps.dtd\">"
	 "<comps>"
	 )))

(define (print-group-closing)
  (map print '("  </packagelist>"
	       " </group>")))
(define (print-group name desc)
  (map print   `(" <group>"
		 ;; TODO: groupreq
		 ,(format "  <id>srpmix-group-~a</id>" name)
		 ,(format "  <name>srpmix-group-~a</name>" name)
		 ;; langonly?
		 ,(format "  <description>~a</description>"
			  (if desc 
			      desc 
			      (format 
			       "Source code for ~a  with canonical directory layout"
			       name)))
		 "  <default>true</default>"
		 "  <uservisible>true</uservisible>"
		 "  <packagelist>"
		 ,(format "   <packagereq type=\"mandatory\">srpmix-weakview-dist-~a</packagereq>" name)
		 ,(format "   <packagereq type=\"mandatory\">srpmix-weakview-packages-~a</packagereq>" name)
		 )))

(define (print-category all-groups)
  (map print `(" <category>"
	       "  <id>srpmix</id>"
	       "  <name>SRPMix</name>"
	       "  <description>Repackaged source code with canonical directory layout</description>"
	       "  <display_order>99</display_order>"
	       "  <grouplist>"
	       ,@(map (cute format "   <groupid>srpmix-groupd-~a</groupid>" <>)
		      all-groups)
	       "  </grouplist>"
	       " </category>")))




(define (print-packages plist)
  (define (build type name)
    (format "   <packagereq type=\"~a\">~a</packagereq>" type name))
  (let ((full-name (cadr (memq :wrapped-name plist)))
	(base-name (cadr (memq :package      plist))))
    (map print `(
		 ,(build 'mandatory (format "srpmix-dir-pkg-~a" base-name))
		 ,(build 'default full-name)
		 ,(build 'optional (format "~a-archives" full-name))
		 ,(build 'optional (format "~a-plugins" full-name))
		 ))))

(define (print-footer)
  (print "</comps>"))

(define es-dest-comps-xml (match-lambda*
			   ((('srpmix-wrap 'name . plist) unused)
			    (print-packages plist)
			    unused)
			   ((('srpmix-group group) all-groups) 
			    (es-dest-comps-xml `(srpmix-group 
						 ,group ,
						 #f)
					       all-groups))
			   ((('srpmix-group name desc) all-groups)
			    (unless (null? all-groups)
			      (print-group-closing))
			    (print-group name desc)
			    (cons name all-groups)
			    )
			   ((#t)
			    (print-header)
			    (list)
			    )
			   ((#f all-groups)
			    (unless (null? all-groups)
			      (print-group-closing))
			    (print-category all-groups)
			    (print-footer)
			    )))
(define (main args)
  (let1 token (es-dest-comps-xml #t)
    (let loop ((r (read))
	       (token token))
      (if (eof-object? r)
	  (es-dest-comps-xml #f token)
	  (let1 token (es-dest-comps-xml r token)
	    (loop (read) token))))))
