;; log-browse-mode.el --- Major mode for browsing a log file
;;
;; Copyright (C) 2008 Masatake YAMATO
;; Copyright (C) 2008 Red Hat, Inc.
;;
;; Author: Masatake YAMATO <yamato@redhat.com>
;;
;; This software is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This software is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this software; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

(define-derived-mode log-browse-mode text-mode "Log Browse"
  "Major mode for browsing a log file"
  (hl-line-mode t)
  (setq buffer-read-only t))

(provide 'log-browse-mode)
;; log-browse-mode.el ends here