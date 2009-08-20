METHOD=ftp
ENABLE=yes
GC=no
BACKUP=no
BUILD=yes
DIST_MAPPING=no

FTP_HOST=ftp.redhat.com
FTP_PATH=/pub/redhat
FTP_PATTERN='*.src.rpm'

