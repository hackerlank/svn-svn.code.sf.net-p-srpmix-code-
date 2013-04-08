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
		 ,(format "   <packagereq type=\"mandatory\">srpmix-weakview-alias-~a</packagereq>" name)
		 )))

(define (print-category all-groups)
  (map print `(" <category>"
	       "  <id>srpmix</id>"
	       "  <name>SRPMix</name>"
	       "  <description>Repackaged source code with canonical directory layout</description>"
	       "  <display_order>99</display_order>"
	       "  <grouplist>"
	       ,@(map (cute format "   <groupid>srpmix-group-~a</groupid>" <>)
		      all-groups)
	       "  </grouplist>"
	       " </category>")))

(define (close-group group)
  (let* ((group (reverse group))
	 (name (car group))
	 (desc (cadr group))
	 (packages (cddr group)))
    (print-group name desc)
    (for-each print-packages packages)
    (print-group-closing)))

(define (open-group name desc)
  (list desc name))

(define (add-package p group)
  (cons p group))

(define (print-packages plist)
  (define (packagereq type name)
    (format "   <packagereq type=\"~a\">~a</packagereq>" type name))
  (let ((full-name (cadr (memq :wrapped-name plist)))
	(base-name (cadr (memq :package      plist))))
    (map print `(
		 ,(packagereq 'mandatory (format "srpmix-dir-pkg-~a" base-name))
		 ,(packagereq 'mandatory full-name)
		 ,(packagereq 'default (format "~a-archives" full-name))
		 ,(packagereq 'optional (format "~a-plugins" full-name))
		 ))))

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
			    (unless (null? all-groups)
			      (close-group current-group))
			    (values (open-group name desc)
				    (cons name all-groups)))
			   ;;
			   ((#t)
			    (print-header)
			    (values #f (list))
			    )
			   ((#f current-group all-groups)
			    (unless (null? all-groups)
			      (close-group current-group))
			    (print-category all-groups)
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
