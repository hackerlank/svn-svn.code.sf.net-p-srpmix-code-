RHEL5
-d 9を iscsidに渡す。
起動スクリプトから渡せないので書き込む。

RHEL4
/etc/sysconfig/iscsiに
DEBUG_ISCSI=9

と書くと id 9 iscsidにわたる。

