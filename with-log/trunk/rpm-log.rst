コマンドラインから-vv

rpmdbの背後にある Berkeley dbについては、

例えば /usr/lib/rpm/macros中の_dbi_configを変更する。
rpm-4.6.0/lib/backend/dbconfig.cを見ると変更項目がわかる。
verboseを設定すると出力最大か。と思ったけど rpmdb->db_errcallが与えられていない
ので実際の出力ハンドラがない。
