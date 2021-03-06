(require 'es)

(define-key minibuffer-local-filename-completion-map [(shift meta ?n)] 'srpmix-history-newer-path)
(define-key minibuffer-local-filename-completion-map [(shift meta ?p)] 'srpmix-history-older-path)

(defun srpmix-history-distro-neighbor (distro prefix newer)
  (if (string-match "\\(.*\\)\\([0-9]\\)$" distro)
      (let* ((distro-prefix (match-string 1 distro))
	     (distro-version (string-to-number (match-string 2 distro)))
	     (neighbor-distro (format "%s%d"
				      distro-prefix
				      (+ distro-version (if newer 1 -1)))))
	(if (file-directory-p (format "%s/%s" prefix neighbor-distro))
	    neighbor-distro
	  nil))
	nil))

(defconst srpmix-history-compare-script
  '(begin (use gauche.version)
	  (use srfi-1)
	  (write (sort (remove 
			(string->regexp "^^.*")
			(port->string-list (current-input-port)))
		       version<?))))

(defun srpmix-history-index-for (version varray)
  (let ((l (length varray))
	(i 0)
	(found nil))
    (while (and (< i l) (not found))
      (if (equal version (aref varray i))
	  (setq found i)
	(setq i (+ i 1))))
    (if found
	found
      nil)))

(defvar srpmix-history-last-prefix nil)
(defvar srpmix-history-last-varray nil)
(defun srpmix-history-version-neighbor (version prefix newer)
  (when (file-directory-p prefix)
    (let ((varray (if (and (equal srpmix-history-last-prefix prefix) 
			   srpmix-history-last-varray)
		      srpmix-history-last-varray
		    (let* ((default-directory prefix)
			   (script (let ((stream (es-make-output-stream ""))) 
				     (es-print srpmix-history-compare-script stream) 
				     (es-stream-get-string stream)))
			   (result (shell-command-to-string (format "ls %s| gosh -e '%s'"
								    prefix
								    script)))
			   (stream (es-make-input-stream result))
			   (varray (apply 'vector (es-read stream))))
		      (setq srpmix-history-last-prefix prefix
			    srpmix-history-last-varray varray)
		      varray))))
	   
	(let ((last-idx (- (length varray) 1))
	      (idx (srpmix-history-index-for version varray)))
	  (if idx
	      (if newer
		  (if (< idx last-idx)
		      (aref varray (+ idx 1))
		    nil)
		(if (< 0 idx)
		    (aref varray (- idx 1))
		  nil))
	    nil)))))


(defun srpmix-history-neighbor-string (contents newer)
  (cond
   ;; /srv/sources/dists/rhel4u7/packages/4/4Suite/*
   ;; /var/lib/srpmix/dists/rhel4u7/packages/4/4Suite/*
   ((string-match 
     "\\(/srv/sources/\\(?:.rawhide/srpmix/\\)?dists/\\|/var/lib/srpmix/dists/\\)\\([^/]+\\)\\(.*\\)"
     contents)
    (let ((prefix (match-string 1 contents))
	  (distro (match-string 2 contents))
	  (rest   (match-string 3 contents)))
      (let ((neighbor-distro (srpmix-history-distro-neighbor distro prefix newer)))
	  (when neighbor-distro
	    (concat prefix neighbor-distro rest)))))
     ;; /srv/sources/packages/4/4Suite/rhel4u4/
     ;; /var/lib/srpmix/packages/4/4Suite/rhel4u4/
     ((string-match 
       "\\(\\(?:/srv/sources/\\(?:.rawhide/srpmix/\\)?packages/\\|/var/lib/srpmix/packages/\\)\\(?:[^/]+\\)/\\(?:[^/]+\\)/\\)\\([^/]+\\)\\(.*\\)"
       contents)
      (let ((prefix (match-string 1 contents))
	    (distro (match-string 2 contents))
	    (rest   (match-string 3 contents)))
	(let ((neighbor-distro (srpmix-history-distro-neighbor distro prefix newer)))
	    (when neighbor-distro
	      (concat prefix neighbor-distro rest)))))
     ;; /srv/sources/sources/4/4Suite/1.0-3/*     
     ;; /var/lib/srpmix/sources/4/4Suite/1.0-3/*
     ;; ---
     ((string-match 
       "\\(\\(?:/srv/sources/\\(?:.rawhide/srpmix/\\)?sources/\\|/var/lib/srpmix/sources/\\)\\(?:[^/]+\\)/\\(?:[^/]+\\)/\\)\\([^/]+\\)\\(.*\\)"
       contents)
      (let ((prefix (match-string 1 contents))
	    (version (match-string 2 contents))
	    (rest   (match-string 3 contents)))
	(let ((neighbor-version (srpmix-history-version-neighbor version prefix newer)))
	    (when neighbor-version
	      (concat prefix neighbor-version rest)))))))

(defun srpmix-history-neighbor-path (newer)
  (let ((replacement (srpmix-history-neighbor-string (minibuffer-contents)
						     newer)))
    (when replacement
      (delete-minibuffer-contents)
      (insert replacement))))

(defun srpmix-history-newer-path ()
  (interactive)
  (srpmix-history-neighbor-path t))

(defun srpmix-history-older-path ()
  (interactive)
  (srpmix-history-neighbor-path  nil))

(provide 'srpmix-history)
