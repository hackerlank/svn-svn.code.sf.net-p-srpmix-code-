;;
;; Copyright (C) 2010 Masatake YAMATO
;;

;; This library is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This library is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this library.  If not, see <http://www.gnu.org/licenses/>.
;;
;; Author: Masatake YAMATO <yamato@redhat.com>
;;
(define-module mperg->html
  (use text.html-lite)
  (use util.list)
  (use es.dest.syslog)
  (use gauche.sequence)
  (use text.tree)
  (export mperg->html))
(select-module mperg->html)


;;
;; Taken from http://www.kanaya440.com/contents/tips/javascript/012.html
;;
(define toggle-script
  "function toggle(ch) {
    var obj=document.all && document.all(ch) || document.getElementById && document.getElementById(ch);
    if(obj && obj.style) obj.style.display=
    \"none\" == obj.style.display ?\"\" : \"none\";
}")

(define highlight-script
  "function highlight(ch) {
    var obj=document.all && document.all(ch) || document.getElementById && document.getElementById(ch);
    if(obj && obj.style) obj.style.backgroundColor= \"gold\";
}")

(define unhighlight-script
  "function unhighlight(ch) {
    var obj=document.all && document.all(ch) || document.getElementById && document.getElementById(ch);
    if(obj && obj.style) obj.style.backgroundColor= \"white\";
}")

(define (javascript-block)
  (html:script :language "JavaScript"
	       :type "text/javascript"
	       (apply string-append
		      (intersperse "\n"
				   `(
				     ,toggle-script
				     ,highlight-script
				     ,unhighlight-script
				     ;; clock-script
				     )))))

(define (kget klist keyword)
  (let1 kdr (memq keyword klist)
    (if kdr
	(cadr kdr)
	#f)))

(define (mperg->html input-port dist srcview)
  (list
   (html-doctype)
   (html:html
    (html:head
     (javascript-block))
    (html:body
     (let1 logline-number -1
       (port-map
	(lambda (r)
	  (set! logline-number (+ logline-number 1))
	  (cond
	   ((kget r :raw) (raw->html r logline-number dist))
	   ((null? (kget r :filelines)) (unsolved->html r logline-number dist))
	   (else (syslog->html r logline-number dist srcview))))
	(pa$ read input-port)))))))


(define (raw->html r l dist)
  (html:pre
   (html:span :class "resolution-level" "[ ]")
   (html:span " ")
   (html:span :class "raw-logline"
	     (html-escape-string 
	      (syslog<-es r)))))

(define (unsolved->html r l dist)
  (html:pre
   (html:span :class "resolution-level" "[_]")
   (html:span " ")
   (html:span :class "unsolved-logline"
	     (html-escape-string 
	      (syslog<-es r)))))

(define (js fn arg1)
  (format "~a('~a')" (x->string fn) arg1))

(define (make-fileline-href srcview package version file line dist)
  (cond
   ((string? srcview)
    (format srcview (substring package 0 1) package version file line))
   (else
    "")))

(define (make-sources-path package version file line dist)
  (format "/srv/sources/sources/~a/~a/~a/~a:~d"
	  (substring package 0 1)
	  package
	  version
	  file
	  line))

(define (syslog->html r l dist srcview)
  (let* (
	 (log-string (syslog<-es r))
	 (filelines (kget r :filelines))
	 (n-filelines (length filelines))
	 (logline-id (format "logline-~d" l))
	 (msgblock-id (format "msgblock-~d" l))
	 )
    (list
     (html:pre (html:span :class "resolution-level" "[*]")
	       (html:span " ")
	       (html:span :class "solved-logline"
			 :id logline-id
			 :onclick (js 'toggle msgblock-id)
			 :onmouseover (js 'highlight logline-id)
			 :onmouseout (js 'unhighlight logline-id)
			 (html-escape-string 
			  log-string)))
     (html:table :border #f 
		 :class "msgblock"
		 :id msgblock-id
		 :style "display: none;"
		 (map-with-index
		  (lambda (msg-index msg)
		    (let ((msg-id (format "msg-~d-~d" l msg-index) )
			  (filelineblock-id (format "filelineblock-~d-~d" l msg-index)))
		    (html:tr
		     (html:th :valign "top" :align "left" 
			      (html:pre
			       :class "msg"
			       :id msg-id
			       :onclick (js 'toggle filelineblock-id)
			       :onmouseover (js 'highlight msg-id)
			       :onmouseout (js 'unhighlight msg-id)
			       (format "[~,,,,5s/~d] ~s" 
				       (car (car msg))
				       (string-length log-string)
				       (cadr (car msg))))
			      (html:td :class "filelineblock"
				       :id filelineblock-id
				       :style "display: none;"
				       (html:ul
					(map-with-index
					 (lambda (fileline-index fileline)
					   (let1 args (list (kget fileline :package)
							    (kget fileline :version)
							    (kget fileline :file)
							    (kget fileline :line)
							    dist)
					     (html:li (html:pre 
						       (html:a 
						      :href (apply make-fileline-href srcview args)
						      (apply make-sources-path args))))))
					(cdr msg)))
				       )))))
		  filelines)))))


(provide "mperg->html")
