qdiskdに-dをつけるとデバッグモード。
/etc/init.d/qdiskdの中に直接書き込むしかない。

ただしrebootの挙動が変わる。具体的にはdebugモードでは自殺(reboot)する箇所で、
しなくなる。


(Fedora 12)
環境変数QDISK_DEBUGからも入れこめる。 getenv("QDISK_DEBUG");が何かを返せば良い。

どこに出る？ syslogか？

まずsyslogには出る。-fをつけてforegroundで起動した場合stdoutにも出る。
つけなかった場合

clulog -> syslogのみ
clulog_pid -> syslogのみ
clulog_and_print -> syslogとstdout

に出る。

