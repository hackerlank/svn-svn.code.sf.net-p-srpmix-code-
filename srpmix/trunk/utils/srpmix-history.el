(define-key minibuffer-local-filename-completion-map [(shift meta ?n)] 'srpmix-history-newer-path)
(define-key minibuffer-local-filename-completion-map [(shift meta ?p)] 'srpmix-history-older-path)



(defun srpmix-history-distro-neighbor (distro newer)
  ;; rhel4u3 -> rhel4u4 -> ... nil
  (if newer
      "DN"
    "DO"))

(defun srpmix-history-version-neighbor (distro newer)
  (if newer
      "VN"
    "VO"))

(defun srpmix-history-neighbor-string (contents
				       distro-level
				       newer)
  (cond
   ;; /srv/sources/dists/rhel4u7/packages/4/4Suite/*
   ;; /var/lib/srpmix/dists/rhel4u7/packages/4/4Suite/*
   ((string-match 
     "\\(/srv/sources/dists/\\|/var/lib/srpmix/dists/\\)\\([^/]+\\)\\(.*\\)"
     contents)
    (let ((prefix (match-string 1 contents))
	  (distro (match-string 2 contents))
	  (rest   (match-string 3 contents)))
      (when distro-level
	(let ((neighbor-distro (srpmix-history-distro-neighbor distro newer)))
	  (when neighbor-distro
	    (concat prefix neighbor-distro rest))))))
     ;; /srv/sources/packages/4/4Suite/rhel4u4/
     ;; /var/lib/srpmix/packages/4/4Suite/rhel4u4/
     ((string-match 
       "\\(\\(?:/srv/sources/packages/\\|/var/lib/srpmix/packages/\\)\\(?:[^/]+\\)/\\(?:[^/]+\\)/\\)\\([^/]+\\)\\(.*\\)"
       contents)
      (let ((prefix (match-string 1 contents))
	    (distro (match-string 2 contents))
	    (rest   (match-string 3 contents)))
	(when distro-level
	  (let ((neighbor-distro (srpmix-history-distro-neighbor distro newer)))
	    (when neighbor-distro
	      (concat prefix neighbor-distro rest))))))
     ;; /srv/sources/sources/4/4Suite/1.0-3/*     
     ;; /var/lib/srpmix/sources/4/4Suite/1.0-3/*
     ;; ---
     ((string-match 
       "\\(\\(?:/srv/sources/sources/\\|/var/lib/srpmix/sources/\\)\\(?:[^/]+\\)/\\(?:[^/]+\\)/\\)\\([^/]+\\)\\(.*\\)"
       contents)
      (let ((prefix (match-string 1 contents))
	    (version (match-string 2 contents))
	    (rest   (match-string 3 contents)))
	(unless distro-level
	  (let ((neighbor-version (srpmix-history-version-neighbor version prefix newer)))
	    (when neighbor-version
	      (concat prefix neighbor-version rest))))))))

(defun srpmix-history-neighbor-path (distro-level newer)
  (let ((replacement (srpmix-history-neighbor-string (minibuffer-contents)
						     distro-level
						     newer)))
    (when replacement
      (delete-minibuffer-contents)
      (insert replacement))))

(defun srpmix-history-newer-path (distro-level)
  (interactive "P")
  (srpmix-history-neighbor-path distro-level t))

(defun srpmix-history-older-path (distro-level)
  (interactive "P")
  (srpmix-history-neighbor-path distro-level nil))
