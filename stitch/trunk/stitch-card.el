(require 'electric)
(require 'stitch)

(defvar stitch-card-current nil)
(defvar stitch-card-forward-list nil)
(defvar stitch-card-backward-list nil)
(defun stitch-card-next ()
  (interactive)
  (if stitch-card-current
      (setq stitch-card-current (cadr (member stitch-card-current stitch-card-forward-list)))
    (setq stitch-card-current (car stitch-card-forward-list)))
  (if stitch-card-current
      (let ((file (stitch-klist-value stitch-card-current :file)))
	(stitch-target-jump stitch-card-current file)
	(backward-char 1)
	(recenter 1)
	(forward-char 1)
	(message "%s" file))
    (setq stitch-card-current (car stitch-card-backward-list))
    (message "%s" "<end>")))

(defun stitch-card-prev ()
  (interactive)
  (when stitch-card-current
    (setq stitch-card-current (cadr (member stitch-card-current stitch-card-backward-list)))
    (if stitch-card-current
	(let ((file (stitch-klist-value stitch-card-current :file)))
	  (stitch-target-jump stitch-card-current file)
	  (backward-char 1)
	  (recenter 1)
	  (forward-char 1)
	  (message "%s" file))
      (setq stitch-card-current (car stitch-card-forward-list))
      (message "%s" "<end>"))))

(defvar stitch-card-mode-map 
  (let ((map (make-sparse-keymap)))
    (define-key map " " 'stitch-card-next)
    (define-key map [backspace] 'stitch-card-prev)
    (define-key map "q" 'stitch-card-mode)
    map))
    
(define-minor-mode stitch-card-mode
  ""
  nil " StitchCard" stitch-card-mode-map :global t)

(defun stitch-card-compile (list)
  (let ((l (with-temp-buffer
	     (let ((l (delete nil (mapcar
				   (lambda (elt)
				     (if (and (listp elt)
					      (eq (car elt) 'stitch-annotation))
					 elt
				       nil))
				   list))))
	       (princ l)
	       (goto-char (point-min))
	       (stitch-load-annotation (current-buffer) "/tmp")
	       
	       l))))
    (let ((L (list)))
      (mapc (lambda (r)
	      (setq L (append (stitch-klist-value r :target-list) L)))
	  l)
      L
      (setq stitch-card-current nil
	    stitch-card-forward-list (reverse L)
	    stitch-card-backward-list L))))

(stitch-card-compile 

'(stitch-card example
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/dists/rhel5su3/packages/k/kernel/pre-build/kernel-2.6.18/linux-2.6.18.i386/include/linux/mmzone.h" :point 4251 :coding-system undecided-unix :line 129 :which-func "per_cpu_pageset")) :annotation-list ((annotation :type text :data "ZONEについての説明。")) :date "Tue Oct 13 22:31:36 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))
(stitch-annotation :version 0 :target-list ((target :type file :file "/var/lib/lcopy/sources/k/kernel/trunk/mm/page_alloc.c" :point 2372 :coding-system undecided-unix :line 84)) :annotation-list ((annotation :type text :data "こまかいコントロールがあるかも。")) :date "Tue Oct 13 23:41:18 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/dists/rhel5su4/packages/k/kernel/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/net/ipv6/tcp_ipv6.c" :point 6649 :coding-system undecided-unix :line 256 :which-func "tcp_v6_connect")) :annotation-list ((annotation :type text :data "ここで rfc3484にもとづき fl.fl6_srcを埋めて、")) :date "Tue Oct 20 21:59:13 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/dists/rhel5su4/packages/k/kernel/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/net/ipv6/tcp_ipv6.c" :point 6922 :coding-system undecided-unix :line 269 :which-func "tcp_v6_connect")) :annotation-list ((annotation :type text :data "もしsrc addrが指定されていなければ、その値をここで設定")) :date "Tue Oct 20 21:59:53 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/dists/rhel5su4/packages/k/kernel/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/net/ipv6/tcp_ipv6.c" :point 7012 :coding-system undecided-unix :line 274 :which-func "tcp_v6_connect")) :annotation-list ((annotation :type text :data "じゃなくてここだった。")) :date "Tue Oct 20 22:08:07 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/dists/rhel4u4/packages/k/kernel/pre-build/kernel-2.6.9/linux-2.6.9/drivers/ide/ide-cd.c" :point 67254) (target :type file :file "/srv/sources/dists/rhel4u4/packages/k/kernel/pre-build/kernel-2.6.9/linux-2.6.9/drivers/ide/ide-cd.c" :point 81578)) :annotation-list ((annotation :type graphviz-dot :data "digraph cdrom_lockdoor {\n        node[shape=plaintext,fontsize=10];\n\tcdrom_lockdoor->\"GPCMD_PREVENT_ALLOW_MEDIUM_REMOVAL\";\n        struct[label=\"cdrom_device_ops ide_cdrom_dops\"];\n\tstruct->ide_cdrom_reset->cdrom_lockdoor;\n\tstruct->ide_cdrom_tray_move->cdrom_lockdoor;\n\tstruct->ide_cdrom_lock_door->cdrom_lockdoor;\n}")) :date "Fri Aug 17 11:18:12 2007" :full-name "Masatake YAMATO" :mailing-address "jet@gyve.org" :keywords (example))
))