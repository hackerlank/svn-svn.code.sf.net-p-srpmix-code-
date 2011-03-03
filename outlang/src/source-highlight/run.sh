#!/bin/bash -x
ctags hello.c
source-highlight --gen-references=inline --ctags-file=./tags --tab=8 --doc --outlang-def=yogomacs.outlang --infer-lang --input=hello.c --output=hello.c.xhtml
