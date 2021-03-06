stitch.el --- your source, my annotation
==========================================

このemacs上で動作するツールを用いると複雑なソースコードを読むにあたり、
そのソースコードに直接メモを書き込むことができます。メモはソースコード本
体とは独立に保存することができます。一度メモを入れたソースコードを再度
emacs上で読み込むとメモも表示されます。

どのようにメモが挿入されるかの例です:

  https://www.codeblog.org/blog/jet/images/20070801_0.png


このツールにはいくつか厳しい制限事項があります。制限事項を良く理解頂いてから
使い方の説明に進んで下さい。


制限事項
=======

- メモを埋め込む先となるソースコードを改変できない。
  メモの埋め込み先をキャラクターオフセットで覚えるので、ソースコードを改変
  すると適切な位置に挿入されません(1)。
  
  
- メモを埋め込む先となるソースコードのファイルシステム上の位置も変更できない。
  メモの埋め込み先の絶対パスも記録するので、そのソースコードのファイルシステム
  上の位置がかわると、メモは追従できません(2)。

- メモを編集するためのユーザインターフェイスがない。
  メモの作成については、emacs上のメーラと似たように作ってあり誰でも使えると思います。
  一方一度作成したメモについて、それを編集するためのインターフェイスを用意していません。

  メモはソースコードとは独立に、LISP形式(S expression(Sexp))でファイルに保存する
  のでそのファイルを直接編集する必要があります。Sexpの編集が特別難しいとは思いませんが、
  素人がそれについて文句を言うのを何度も見ました。

- Emacsが巨大なメモをうまく表示できない。

- 作者自身が以上の制約を克服するつもりはない。

- (1), (2): text render、挿入先がファイルに限り多少改良した。メモ挿入時、
  挿入先前後の文字列(近隣文字列)を記録しておき、メモを挿入したファイル
  (オリジナルファイル)と同じbasenameを持つファイルをオープンした場合、
  キャラクターオフセットを基準に近隣文字列が良く一致する箇所を探して、
  そこにメモを挿入する。オリジナルファイルについては、read-only であれ
  ばキャラクターオフセットだけを使う(3)。read-onlyでなければ近隣文字列
  による探索を行う。あるソフトウェアのあるソースコードのメモを作成した
  後、同じソフトウェアの異なるバージョンをfind-fileしたとき異なるバージョ
  ンのソースコード上でも、そのメモを閲覧できることを目的として実装した。

- (3): 現在機能していないかもしれない。

使い方
=======

メモの挿入
---------

0. stitch.elをどこか適当なディレクトリに置いて下さい。

3. .emacsに以下のコードを記述してemacsを再起動します。

   (load-library "適当なディレクトリ/stitch.el")

4. メモを取りたいリードオンリーのファイルを開きます。


5. メモを挿入してみたい箇所にテキストカーソルを移動します。

6. \C-x 4 A (control-X 4 A)のキーを押します。メモを取るための新しいバッファが開きます。

7. あたらしいバッファにメモを書きます。

8a. もしメモを破棄したければ、このバッファで\C-x kして下さい。これはemacsそのものの使い
    方なので、これ以上は解説しません。

8b. メモを残したいなら\C-c\C-c でメモをコミットします。

   このときemacsがメモに対するキーワードを尋ねてきます。stitch.elのキーワード検索
   機能が、このキーワードを使います。何も指定しないこともできますが、実際の仕事で活用
   するのであれば、その仕事に応じたキーワードを付与しておくと良いです。

   作者は、お客様からの技術的な質問に回答する仕事をしています。そこで仕事の過程でソース
   コードにメモを取る場合には 「お客様の名前-問い合わせのサブジェクト」、
   といった文字列をキーワードにしています。仕事と直接関係がない場合にはreading-xxx 
   といったキーワードを使っています。

   キーワードは複数付与することができるので、emacsも複数回キーワードを尋ねてきます。
   もうこれ以上キーワードを付与したくない場合は、何もキーワードを与えずに「リターン」
   すれば、コミット完了です。

9. もともとのテキストカーソルの位置にメモが挿入されたはずです。
   ソースコードを\C-x\C-vで読み直したり、emacsを再起動しても、メモが再挿入される
   はずです。


メモの編集
---------
   
1. 特に設定しなければメモは~/.stitch.esに記録されます。編集したい場合は
   気合いでがんばって下さい。タイポを直したくなるのはわかりますが、読み
   間違いに関しては別のメモを貼り付けて例えば


    前のメモは間違いだった。読み直してみると、タイマーではキャッシュは破棄されない。


    といった感じで訂正する方が作業記録として良いと思います。\C-x A Fで~/.stitch.es
    を開くことができます。編集が終ったら\C-x kしても構いません。

2. ~/.stitch.esを編集した場合 \C-x A g でメモを読み直し、表示を更新します。

メモの間の移動
-------------

単一のバッファ内に複数のメモがある場合 

   \C-x A n
   \C-x A p

で移動できます。


メモの一覧
-------------

特定のキーワードに関してメモの一覧を表示することができます。

    \C-x A L

とすると、キーワードを尋ねてきます。AND検索するので、1つ以上のキーワードを
入れて、最後にキーワードを空のまま「リターン」して下さい。


将来説明すべきその他の機能
=======================

- メモの共有
- graphviz

