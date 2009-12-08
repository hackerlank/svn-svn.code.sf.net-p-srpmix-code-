qdiskdに-dをつけるとデバッグモード。
/etc/init.d/qdiskdの中に直接書き込むしかない。
ただしrebootの挙動が変わる。

(Fedora 12)
環境変数QDISK_DEBUGからも入れこめる。 getenv("QDISK_DEBUG");が何かを返せば良い。

どこに出る？ syslogか？
