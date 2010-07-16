export SYNTAX_OUTPUT_FILE=/tmp/Kconfig.html
rm $SYNTAX_OUTPUT_FILE
vim -n -u NONE -i NONE -N -S ~/var/srpmix/syntax/syntax-batch.vim -- /srv/sources/attic/cradles/lcopy.sys/mirror/k/kernel/trunk/pre-build/linux-2.6/drivers/Kconfig 
gosh ~/var/srpmix/syntax/htmlprag-0-16.scm < $SYNTAX_OUTPUT_FILE  > $(dirname $SYNTAX_OUTPUT_FILE)/$(basename $SYNTAX_OUTPUT_FILE .html).shtml
