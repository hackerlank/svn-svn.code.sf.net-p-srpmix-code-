# 
# Copyright (C) 1992, 1993, 1994, 1995, 1996, 1997, 1998, 2000, 2001,
#   2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009
#   Free Software Foundation, Inc.
#
# This file is part of GNU Emacs.
#
# GNU Emacs is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GNU Emacs is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Emacs; see the file COPYING.  If not, write to the
# Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
# Boston, MA 02110-1301, USA.

import gdb

class Emacs (gdb.Command):
    """Show backtrace in elisp layer"""
    def __init__(self):
        super (Emacs, self).__init__("emacs-backtrace", 
                                     gdb.COMMAND_STACK)
    def xgettype(self, function):
        
    def invoke (self, arg, from_tty):
        base = gdb.parse_and_eval ("backtrace_list")
        cur  = base
        while cur != 0:
            type = self.xgettype(cur["function"])
                                     
                                     

