(define-module font-lock.harnesses.daemonize
  (export <daemonize-harness>
	  launch)
  (use font-lock.harness)
  (use gauche.process)
  )

(select-module font-lock.harnesses.daemonize)


;; Taken from http://d.hatena.ne.jp/rui314/20070809/p1
(define (daemonize parent child)
  ;; forkし、親は即座に終了する。親と子が別々にバッファをフラッシュす
  ;; ると同一の内容が2度書き出されてしまうので、終了処理を行わずに即座
  ;; に終了するためsys-exitを呼ぶ。(sys-exitの代わりにexitを呼ぶと終了
  ;; 処理が2度走ってしまう。)
  (if (positive? (sys-fork))
      (parent)
      (begin
	;; 新たなグループのプロセスグループリーダと、セッションリーダになり、
	;; 制御端末を持たない状態になる。
	(sys-setsid)
	;; ルートにカレントディレクトリを移動する。
	(sys-chdir "/")
	;; ファイル作成モードマスクを0にする。
	(sys-umask 0)
	;; 標準入力、標準出力、標準エラー出力を/dev/nullにリダイレクトする。
	(call-with-input-file "/dev/null"
	  (cut port-fd-dup! (standard-input-port) <>))
	(call-with-output-file "/dev/null"
	  (lambda (out)
	    (port-fd-dup! (standard-output-port) out)
	    (port-fd-dup! (standard-error-port) out)))
	(child)
	)
      ))

(define-class <daemonize-harness> (<harness>)
  ((name :init-value "daemonize")))
(define-harness (make <daemonize-harness>))

(define-method launch ((daemonize-harness <daemonize-harness>)
		       cmdline
		       params
		       verbose
		       )
  (let/cc return
  (daemonize
   (lambda () (return 0))
   (lambda ()
     (let1 proc (run-process cmdline :wait #f)
       (process-wait proc)
       (process-exit-status proc))))))

(provide "font-lock/harnesses/daemonize")
