;; -*- tour-edit -*-
(deftour Mapped-in-meminfo
  "/proc/meminfo中のMappedの値の出所について"
  (
   (C "* page毎にマップされた回数を保持するフィールド_mapcountを持つ[_mapcount]。
  同じページが複数箇所にマップされればその数は増える。
* マップされているページフレームの合計はnr_mappedなる変数で数えている[inc-nr_mapped]。
* あるページが複数箇所にマップされていても、nr_mappedに重複分は計上されない[mapcount-init][inc-nr_mapped]。
  言いかえると、マップされている箇所の数ではなく、マップされているページフレームを数える。
* mmapしたときではなくページフォルトが発生した後の処理で計上する[do-account]。" :subject "概要")
   (A "52b1233a-95ab-40d4-9e52-0dee037b52d2" :label "_mapcount" 
      :subject "参照を保持するフィールド" :context (0 4))
   (A "42caf43a-0e01-4d57-9e28-f0b25d3ddda2" :label "mapcount-init" 
      :subject "初期化" :context (0 4))
   (A "7568632e-3b27-46e2-9c27-d87feb63b334" :label "inc-nr_mapped" :context (0 3)
      :subject "->_mapcountの値に基づくnr_mappedの計算")
   (A "f9b1ca19-6441-4913-8035-d3f4c7697042" :label "do-account")
   ))

(deftour Committed_AS-in-meminfo
  "/proc/meminfo中のCommitted_ASの値の出所について"
  (
   78b4cd17-0baa-49e4-8a26-88aeb4af838d
   ff536c5a-e93a-429b-a9dd-426a01831d1b
   ;; (tour checking-overcommit)
   )
  )

(deftour  checking-overcommit
  "Overcommitをチェックしている箇所について"
  (
   012b28a2-1fac-4955-bf98-156e7f22059c
   38541604-c875-479d-9e05-7efcb6c96b3a

   c37e8fbb-881f-452e-a07d-542a5e78640e
   2a081130-9516-4d80-832d-d557a9423f2c
   db467d01-6b96-4a70-b132-60f0bc3413fd
   2736d2bc-41d6-4ffa-9950-62806fe18e4b
   ;;
   
   )
)

(deftour gso
  "gsoについて"
  (
   "tcp-segmentation-offload(tso)やudp-fragmentation-offload(ufo)が
具体的にどういった処理をしているのかを知りたい。そこでハードウェアによる
オフロードが使えない場合に代替として実行されるソフトウェア箇所gsoについて
調べる。"
   ))
