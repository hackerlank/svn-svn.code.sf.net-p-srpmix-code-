/srv/sources/sources/s/squid/2.6.STABLE6-5.el5_1.3/pre-build/squid-2.6.STABLE6/src/debug.c


ログの読み方:
http://squid.robata.org/faq_6.html

squidでは、ログという言葉に複数の意味があるので注意を要する。

squid.confで

	debug_options ALL,9

とすると/var/log/squid/cache.logに大量に出る。

ALLがカテゴリで9がレベル。レベルは高いほど詳細に
出て10がmax. 10はメモリアロケーションの情報まで
出るので、通常はやりすぎ。 -Xオプションをつけた場合や
SIGUSR2を送信した場合 ALL, 10となる[0]。


_db_levelはデバッグメッセージ毎に設定される。
まずdebug_optionsで設定した以下の_db_levelを持つメッセージは
出力の対象となる。

出力先
---------
出力先は3系統ある[1]。

O1. /var/log/squid/cache.log
O2. stderr
O3. syslog

O1. については squid.confのcache_logで変更できる。ソースコード中では
Config.Log.log.  デフォルトでcache.logへの書き込みはバッファリングされ
る。バッファリングを無効にしたければ squid.conf中でbuffered_logs off 
とする。ファイルへは上書きではなく追記される。したがってファイルサイズ
に注意する。cache_logを設定していない場合stderrへ行く。O2.と重複
するのでO2.の系統が無効になる。

O2. コマンドラインオプション -d N (N =< 9)とすると標準エラー出力に
ログが出る。ただしNより大きい_db_levelを持つメッセージは出てこない。
このNに関する検査はdebug_optionsに関する検査の後になされる。従って
Nをいくら大きな値にしてもdebug_optionsに関する検査をパスしていない
メッセージは出力されない。

-d NのNはコード中ではopt_debug_stderrに設定される。

O3. コマンドラインオプション -s をつけて起動した場合
    _db_levelが1以下の重要なメッセージについて、syslogに出ていく。
    -sオプションを指定した場合、コード中ではopt_syslog_enableが1となる。

initスクリプト
---------------------
/etc/sysconfig/squid.sysconfigのSQUID_OPTSに必要コマンドラインオプショ
ンを設定する。

stderr, stdoutともに/var/log/squid/squid.outへ追記される。




[0] sigusr2_handle() in /srv/sources/sources/s/squid/2.6.STABLE6-5.el5_1.3/pre-build/squid-2.6.STABLE6/src/tools.c
[1] _db_print() in /srv/sources/sources/s/squid/2.6.STABLE6-5.el5_1.3/pre-build/squid-2.6.STABLE6/src/debug.c
[2] start() in /srv/sources/dists/rhel5su5/packages/s/squid/archives/squid.init

