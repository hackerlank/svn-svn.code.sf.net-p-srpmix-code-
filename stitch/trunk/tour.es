;; -*- tour-edit -*-
(deftour Mapped-in-meminfo
  "/proc/meminfo中のMappedの値の出所について"
  (
   "/proc/meminfo中のMappedの値の出所について
-------------------------------------------
* 複数箇所にマップされていても、重複分は計上されない[mapcount-init][inc-nr_mapped]。
* mmapしたときではなくページフォルトが発生した後の処理で計上する[do-account]。
"
   (A "42caf43a-0e01-4d57-9e28-f0b25d3ddda2" :label "mapcount-init")
   (A "7568632e-3b27-46e2-9c27-d87feb63b334" :label "inc-nr_mapped")
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
