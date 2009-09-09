repo --name=f10 --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-10&arch=i386
repo --name=f10-update --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f10&arch=i386
repo --name=f10-build --baseurl=http://koji.fedoraproject.org/repos/dist-f10-build/latest/i386/
repo --name=srpmix --baseurl=file:/srv/sources/archives/srpmix/redhat-srpmix/

rootpw --iscrypted $1$kd3X1W.R$qCIIqc9tdijJmP6wzcjii/
authconfig --enableshadow --enablemd5
services --enabled=nfs,httpd
part / --fstype ext2 --size=250000
firewall --service=ssh
selinux --disabled
timezone --utc Asia/Tokyo

%packages
@core
@base
bash
kernel
passwd
policycoreutils
chkconfig
authconfig
rootfiles

@web-server
@ftp-server
@smb-server

srpmix
#srpmix-plugin-*
#@srpmix-rhel* --optional
*-srpmix
hyperestraier

%end

%post

sh -x /etc/cron.daily/srpmix.daily
find /usr/share/srpmix/ -name '*.swrf' | xargs rm

#PATH=/bin:/usr/bin:/sbin:/usr/sbin srpmix-plugin
FIND_OPTIONS=' ' sh -x /etc/cron.daily/srpmix.daily

estcmd repair -rsh /var/lib/srpmix/extra/hyperestraier/idx
/usr/share/srpmix/utils/srpmix-hyperestraier

echo "/srv/sources	*(ro)" > /etc/exports
test -e /srv/sources && rm /srv/sources
ln -s /var/lib/srpmix /srv/sources
cat > /etc/httpd/conf.d/welcome.conf <<'EOF'
Alias /sources /srv/sources
<Location /sources>
	Options Indexes FollowSymlinks
</Location>
EOF

%end

