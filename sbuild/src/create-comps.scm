#!/bin/sh
#| -*- scheme -*- |#
:; exec gosh -- $0 "$@"

;; > STDIN
;;  (srpmix-wrap  ... :package PACKAGE ... :wrapped-name WRAPPED-NAME ...)
;;  (srpmix-group name [desc])

(use util.match)
(use srfi-11)

(define (print-header)
  (map print 
       '("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	 "<!DOCTYPE comps PUBLIC \"-//Red Hat, Inc.//DTD Comps info//EN\" \"comps.dtd\">"
	 "<comps>"
	 )))

(define (print-group-closing)
  (map print '("  </packagelist>"
	       " </group>")))

(define (print-category all-groups)
  (map print `(" <category>"
	       "  <id>srpmix</id>"
	       "  <name>SRPMix</name>"
	       "  <description>Repackaged source code with canonical directory layout</description>"
	       "  <display_order>99</display_order>"
	       "  <grouplist>"
	       ,@(map (cute format "   <groupid>srpmix-group-~a</groupid>" <>)
		      (reverse all-groups))
	       "  </grouplist>"
	       " </category>")))

(define (print-group name desc extra)
  (for-each print `(" <group>"
		 ;; TODO: groupreq
		 ,(format "  <id>srpmix-group-~a</id>" name)
		 ,(format "  <name>srpmix-group-~a</name>" name)
		 ;; langonly?
		 ,(format "  <description>~a</description>" desc
			  )
		 "  <default>true</default>"
		 "  <uservisible>true</uservisible>"
		 "  <packagelist>"
		 ,@(map (cute string-append "   <packagereq type=\"mandatory\">" <> "</packagereq>")
			extra))))

(define (close-group group all-groups)
  (define (full-name p)
    (cadr (memq :wrapped-name p)))
  (define (base-name p)
    (cadr (memq :package p)))
  (define (srpmix-dir-pkg- p)
    (format "srpmix-dir-pkg-~a" (base-name p)))
  (let* ((group (reverse group))
	 (name (car group))
	 (archives-name #`",|name|-archives")
	 (plugins-name #`",|name|-plugins")
	 (desc-not-used-now (cadr group))
	 (packages (cddr group)))
    (print-group name
		 #`"Source code for ,|name|  with canonical directory layout"
		 (list
		  #`"srpmix-weakview-dist-,|name|"
		  #`"srpmix-weakview-packages-,|name|"
		  #`"srpmix-weakview-alias-,|name|"
		 ))
    (for-each (^ (p) (print-packages (full-name p)
				     (list (srpmix-dir-pkg- p))))
		 packages)
    (print-group-closing)
    ;;
    (print-group archives-name
		 #`"orignal source code and patches for ,|name|"
		 (list))
    (for-each (^ (p) (print-packages #`",(full-name p)-archives"
				     (list)))
		 packages)
    (print-group-closing)
    ;;
    (print-group plugins-name
		 #`"plugins data for ,|name|"
		 (list))
    (for-each (^ (p) (print-packages #`",(full-name p)-plugins"
				     (list)))
		 packages)
    (print-group-closing)
    ;;
    (cons* plugins-name archives-name all-groups)
    ))

(define (open-group name desc)
  (list desc name))

(define (add-package p group)
  (cons p group))

(define (print-packages full-name extra)
  (define (packagereq type name)
    (format "   <packagereq type=\"~a\">~a</packagereq>" type name))
  (map print `(,@(map (^ (e0) (packagereq 'mandatory e0)) extra)
	       ,(packagereq 'mandatory full-name)
	       )))

(define (print-footer)
  (print "</comps>"))

(define es-dest-comps-xml (match-lambda*
			   ((('srpmix-wrap 'name . plist) current-group all-groups)
			    (values (add-package plist current-group) all-groups))
			   ;;
			   ((('srpmix-group group) current-group all-groups) 
			    (es-dest-comps-xml `(srpmix-group 
						 ,group ,
						 #f)
					       current-group
					       all-groups))
			   ;;
			   ((('srpmix-group name desc) current-group all-groups)
			    (values (open-group name desc)
				    (cons name (if (null? all-groups)
						   all-groups
						   (close-group current-group all-groups)))))
			   ;;
			   ((#t)
			    (print-header)
			    (values #f (list))
			    )
			   ((#f current-group all-groups)
			    (print-category (if (null? all-groups)
						all-groups
						(close-group current-group all-groups)))
			    (print-footer)
			    )))

(define (main args)
  (let-values (((current-group all-groups) (es-dest-comps-xml #t)))
    (let loop ((r (read))
	       (current-group current-group)
	       (all-groups all-groups))
      (if (eof-object? r)
	  (es-dest-comps-xml #f current-group all-groups)
	  (let-values (((current-group all-groups) (es-dest-comps-xml r 
								      current-group
								      all-groups)))
	    (loop (read) current-group all-groups))))))
