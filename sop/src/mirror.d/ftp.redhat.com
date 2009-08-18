METHOD=ftp
ENABLE=yes
GC=no
BACKUP=yes


FTP_HOST=ftp.redhat.com
FTP_PATH=/pub/redhat
FTP_PATTERN='*.src.rpm'

