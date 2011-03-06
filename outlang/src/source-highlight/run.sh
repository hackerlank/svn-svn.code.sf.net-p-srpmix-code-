#!/bin/bash -x
ctags -n hello.c bar.c
strace -f -e execve source-highlight --gen-references=inline --ctags= --ctags-file=./tags --tab=8 --doc --outlang-def=yogomacs.outlang --infer-lang --input=hello.c --output=hello.c.xhtml
strace -f -e execve source-highlight --gen-references=inline --ctags= --ctags-file=./tags --tab=8 --doc --outlang-def=yogomacs.outlang --infer-lang --input=bar.c --output=bar.c.xhtml
