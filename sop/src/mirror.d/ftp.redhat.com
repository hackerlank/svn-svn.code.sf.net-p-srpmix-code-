METHOD=ftp
ENABLE=yes
GC=no
BACKUP=yes
BUILD=yes

FTP_HOST=ftp.redhat.com
FTP_PATH=/pub/redhat
FTP_PATTERN='*.src.rpm'

