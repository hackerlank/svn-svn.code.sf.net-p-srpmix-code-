_`Linux kernel`
========================================================================

_`dmesgコマンド`
------------------------------------------------------------------------

使い方
........................................................................

linuxカーネルのログはカーネル内のリングバッファに格納されます。このリン
グバッファの内容を見るにはいくつか方法があります。dmesgコマンドを使うの
が方法の一つです。

シェルコマンドラインからdmesgを引数なしで呼び出すと、標準出力を介してリングバッ
ファの内容を取得できます。

取得例
........................................................................
::

    $ dmesg
    Linux version 2.6.18-53.1.4.el5xen (brewbuilder@hs20-bc2-4.build.redhat.com) (gcc version 4.1.2 20070626 (Red Hat 4.1.2-14)) #1 SMP Wed Nov 14 11:05:57 EST 2007
    BIOS-provided physical RAM map:
     Xen: 0000000000000000 - 00000000f1b52000 (usable)
    3139MB HIGHMEM available.
    727MB LOWMEM available.
    Using x86 segment limits to approximate NX protection
    On node 0 totalpages: 990034
      DMA zone: 186366 pages, LIFO batch:31
      HighMem zone: 803668 pages, LIFO batch:31
    found SMP MP-table at 000f4f80

ログレベル
........................................................................

ログメッセージには整数値で表現された重要度が付与されています。

記録する側のlinux開発者が重要度を明示的に指定することができます。
指定しない場合デフォルト値が使われます。

重要度は以下の種類があります。0が最も重要です。7はデバッグ目的で
システムを運用する立場からは、不要な情報のはずです。::

   #define KERN_EMERG    "<0>"  /* system is unusable               */
   #define KERN_ALERT    "<1>"  /* action must be taken immediately */
   #define KERN_CRIT     "<2>"  /* critical conditions              */
   #define KERN_ERR      "<3>"  /* error conditions                 */
   #define KERN_WARNING  "<4>"  /* warning conditions               */
   #define KERN_NOTICE   "<5>"  /* normal but significant condition */
   #define KERN_INFO     "<6>"  /* informational                    */
   #define KERN_DEBUG    "<7>"  /* debug-level messages             */


