``--enable-debug``をつけて``configure``するとソースコード中の``D``マクロが有効になる。
Dマクロは _PAM_LOGFILEに定義されたファイルが存在すればそのファイルに追記する。
_PAM_LOGFILEのデフォルトは
0.77.* => /tmp/pam-debug.log
0.99.* => /var/run/pam-debug.log
存在しなければstderrにログを出す。

pam_rootok.soにdebugをつけると /var/log/messagesにログが出る。
/var/log/secureかも。
