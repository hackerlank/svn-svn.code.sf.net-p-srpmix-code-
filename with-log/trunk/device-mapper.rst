dm_log_init()関数でログハンドラを押し込み
dm_log_init_verboseでログレベルを押し込む(_verbosity)。
_verbosityの値はログハンドラに渡されるだけなので、独自の
ログハンドラはそれを参照しても良いが、無視もできてしまう。

dm_log_initで設定しない場合、device-mapperデフォルトのハンドラが
使われる。これはきっちり.. _verbosityを見る。
