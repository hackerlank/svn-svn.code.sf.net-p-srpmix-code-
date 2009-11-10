export LANG=C
dir=$1
lcopies=${dir}/*.lcopy

cat <<"EOF"
confddir = $(sysconfdir)/lcopy/conf.d
dist_confd_DATA = \
	\
EOF

for x in $lcopies; do
    svn    add   $(basename $x) > /dev/stderr
    printf "	%s \\\\\n" $(basename $x)
done
echo '	\'
echo '	$(NULL)'
