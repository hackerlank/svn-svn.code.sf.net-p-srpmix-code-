``--enable-debug``をつけて``configure``するとソースコード中の``D``マクロが有効になる。
Dマクロは _PAM_LOGFILEに定義されたファイルが存在すればそのファイルに、存在しなければstderr
にログを出す。
