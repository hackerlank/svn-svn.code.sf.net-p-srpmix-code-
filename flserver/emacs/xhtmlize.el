;;; cssize.el -- Convert buffer to xhtml
;;
;; Copyright (C) 2009 Masatake YAMATO
;; Copyright (C) 1997,1998,1999,2000,2001,2002,2003,2005,2006 Hrvoje Niksic
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;; This program is derived from htmlize.el written by 
;; Hrvoje Niksic <hniksic@xemacs.org>.

(require 'cl)

(provide xhtmlize)