;; -*- scheme -*-
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemconfig.c" :point 8802 :coding-system undecided-unix :line 297 :surround ("
" "" "	strcpy (totem_config->rrp_mode, \"none\");
") :which-func ("totem_config_read"))) :annotation-list ((annotation :type text :data "active,passive,noneからデフォルトはnone。")) :date "Mon Nov 16 02:16:02 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemudp.c" :point 49674 :coding-system undecided-unix :line 1875 :surround ("
" "" "int totemudp_mcast_noflush_send (
	void *udp_context,") :which-func ("totemudp_mcast_noflush_send"))) :annotation-list ((annotation :type text :data "threadsがonの場合キューに入るが、そうでなければ、totemudp_mcast_flush_sendと同じ。")) :date "Mon Nov 16 02:18:29 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemrrp.c" :point 14495 :coding-system undecided-unix :line 580 :surround ("{
" "" "	totemnet_token_target_set (instance->net_handles[0], token_target);
}") :which-func ("none_token_target_set"))) :annotation-list ((annotation :type text :data "interfaceを引数に渡しているが、使っていない。single ring?")) :date "Mon Nov 16 02:48:57 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemrrp.c" :point 23893 :coding-system undecided-unix :line 922 :surround ("
" "" "static void passive_token_target_set (
	struct totemrrp_instance *instance,") :which-func ("passive_token_target_set"))) :annotation-list ((annotation :type text :data "activeでもpassiveでも同じ。各インターフェイス毎に処理している。")) :date "Mon Nov 16 02:50:11 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 27162 :coding-system undecided-unix :line 1080 :surround ("                if (quorum_device->state == NODESTATE_DEAD) {
" "" "                        quorum_device->state = NODESTATE_MEMBER;
                        recalculate_quorum(0, 0);") :which-func ("do_cmd_poll_quorum_device"))) :annotation-list ((annotation :type text :data "quorum deviceを1ノードとみなしてメンバーにている。")) :date "Wed Nov 18 02:33:47 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 24651 :coding-system undecided-unix :line 1016 :surround ("			if (!errors)
" "" "				cman_poll_quorum_device(ctx->qc_ch, 1);
") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "ここでquorumデバイスがあたかもノードとして与えられたvoteを維持。")) :date "Wed Nov 18 02:38:25 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 25276 :coding-system undecided-unix :line 1036 :surround ("				if (!errors)
" "" "					cman_poll_quorum_device(ctx->qc_ch, 1);
			}") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "???")) :date "Wed Nov 18 02:39:26 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 21604 :coding-system undecided-unix :line 903 :surround ("				} else {
" "" "					cman_poll_quorum_device(ctx->qc_ch, 0);
				}") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "quorumデバイスのvoteを破棄")) :date "Wed Nov 18 02:40:03 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 7491 :coding-system undecided-unix :line 288 :surround ("
" "" "	list_iterate(nodelist, &cluster_members_list) {
		node = list_item(nodelist, struct cluster_node);") :which-func ("calculate_quorum"))) :annotation-list ((annotation :type text :data "参加しているノード全員のvotesの和を計算(total_votes)
参加しているノード全員のexpected votesのうち最大のものを求める(highest_expected)")) :date "Wed Nov 18 02:43:09 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 7760 :coding-system undecided-unix :line 298 :surround ("	}
" "" "	if (quorum_device && quorum_device->state == NODESTATE_MEMBER)
		total_votes += quorum_device->votes;") :which-func ("calculate_quorum"))) :annotation-list ((annotation :type text :data "quorum_deviceが有効であれば、それに与えられているvoteを加算")) :date "Wed Nov 18 02:44:21 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 25276 :coding-system undecided-unix :line 1036 :surround ("				if (!errors)
" "" "					cman_poll_quorum_device(ctx->qc_ch, 1);
			}") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "これだと masterでもmasterでなくともvoteをかせげる。")) :date "Wed Nov 18 11:18:29 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 32464 :coding-system undecided-unix :line 1285 :surround ("	case CMAN_CMD_ISQUORATE:
" "" "		return cluster_is_quorate;
") :which-func ("process_command"))) :annotation-list ((annotation :type text :data "この変数を見ればquorateかどうかわかる。")) :date "Wed Nov 18 11:20:06 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/lib/libcman.h" :point 2306 :coding-system undecided-unix :line 62 :surround ("typedef enum {CMAN_REASON_PORTCLOSED,
" "" "	      CMAN_REASON_STATECHANGE,
              CMAN_REASON_PORTOPENED,")) (target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/cnxman-socket.h" :point 4173 :coding-system undecided-unix :line 104 :surround ("#define EVENT_REASON_PORTCLOSED   0
" "" "#define EVENT_REASON_STATECHANGE  1
#define EVENT_REASON_PORTOPENED   2"))) :annotation-list ((annotation :type text :data "CMAN_REASON_STATECHANGE == EVENT_REASON_STATECHANGE")) :date "Wed Nov 18 12:03:31 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/group/daemon/cman.c" :point 3171 :coding-system undecided-unix :line 129 :surround ("		break;
" "" "	case CMAN_REASON_STATECHANGE:
		statechange();") :which-func ("cman_callback"))) :annotation-list ((annotation :type text :data "cman daemonのrecalculate_quorumから来る。")) :date "Wed Nov 18 12:05:46 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/fence/fenced/agent.c" :point 6102 :coding-system undecided-unix :line 297 :surround ("
" "" "	/* Mark it as fenced */
	if (!cman_get_node(ch, 0, &node))") :which-func ("update_cman"))) :annotation-list ((annotation :type text :data "fencingが完了したことを伝えるために、cmanを呼ぶ。")) :date "Thu Nov 19 11:46:29 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/r/readline/6.0-3.fc12/pre-build/readline-6.0/text.c" :point 9679 :coding-system undecided-unix :line 435 :surround ("/* Move forward a word.  We do what Emacs does.  Handles multibyte chars. */
" "" "int
rl_forward_word (count, key)") :which-func ("rl_end_of_line"))) :annotation-list ((annotation :type text :data "forward char")) :date "Wed Jan 20 02:50:01 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (readline-subword))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/o/openssh/4.3p2-36.el5_4.4/pre-build/openssh-4.3p2/auth.c" :point 7400 :coding-system undecided-unix :line 251 :surround ("
" "" "	authlog(\"%s %s for %s%.100s from %.200s port %d%s\",
	    authmsg,") :which-func ("auth_log"))) :annotation-list ((annotation :type text :data "%.100sで長すぎる名前の入力を遮断している。")) :date "Tue Mar 16 02:17:03 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (just-reading security))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/j/java-1.6.0-openjdk/1.6.0.0-35.b17.fc13/vanilla/hotspot/src/share/vm/runtime/thread.cpp" :point 135818 :coding-system undecided-unix :line 3734 :surround ("// Threads::print_on() is called at safepoint by VM_PrintThreads operation.
" "" "void Threads::print_on(outputStream* st, bool print_stacks, bool internal_format, bool print_concurrent_locks) {
  char buf[32];") :which-func ("Threads::print_on"))) :annotation-list ((annotation :type text :data "javaのスタックトレース")) :date "Wed Apr  7 05:33:50 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (xbacktrace))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/jet/var/emacs/trunk/src/.gdbinit" :point 27159 :coding-system undecided-unix :line 1185 :surround ("
" "" "define xbacktrace
  set $bt = backtrace_list") :which-func ("xbacktrace"))) :annotation-list ((annotation :type text :data "emacsのバックトレース")) :date "Wed Apr  7 05:34:10 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (xbacktrace))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/fence/fenced/group.c" :point 3576 :coding-system undecided-unix :line 162 :surround ("
" "" "	gh = group_init(NULL, \"fence\", 0, &callbacks, GROUPD_TIMEOUT);
	if (!gh) {") :which-func ("setup_groupd"))) :annotation-list ((annotation :type text :data "group_initの引数のレベル(ここでは0)で通知の優先度が決まるのか？")) :date "Sun Apr 18 22:03:20 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-cluster))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/^lcopy-trunk/pre-build/linux-2.6/net/unix/af_unix.c" :point 26510 :coding-system undecided-unix :line 1036 :surround ("
" "" "	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr &&
	    (err = unix_autobind(sock)) != 0)") :which-func ("unix_stream_connect"))) :annotation-list ((annotation :type text :data "!u->addr: バインドされていなかったら。")) :date "Sun May 16 04:03:12 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-lsof-cant-identify-protocol))
(stitch-annotation :version 0 :target-list ((target :type file :file "/net/sop/srv/sources/attic/cradles/lcopy.sys/mirror/k/kernel/trunk/pre-build/linux-2.6/net/ipv4/af_inet.c" :point 19440 :coding-system undecided-unix :line 778 :surround ("		if (sk->sk_prot->shutdown)
" "" "			sk->sk_prot->shutdown(sk, how);
		break;") :which-func ("inet_shutdown"))) :annotation-list ((annotation :type text :data "ここで tcp_shutdown を呼ぶ。")) :date "Tue May 18 01:14:13 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-lsof-cant-identify-protocol))
(stitch-annotation :version 0 :target-list ((target :type file :file "/net/sop/srv/sources/attic/cradles/lcopy.sys/mirror/k/kernel/trunk/pre-build/linux-2.6/net/ipv4/tcp.c" :point 49642 :coding-system undecided-unix :line 1865 :surround ("		/* Clear out any half completed packets.  FIN if needed. */
" "" "		if (tcp_close_state(sk))
			tcp_send_fin(sk);") :which-func ("tcp_shutdown"))) :annotation-list ((annotation :type text :data "sk->sk_shutdownにhowが設定されている。")) :date "Tue May 18 01:18:43 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-lsof-cant-identify-protocol))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.9-89.EL/pre-build/kernel-2.6.9/linux-2.6.9/configs/kernel-2.6.9-x86_64.config" :point 117 :coding-system undecided-unix :line 6 :surround ("#
" "" "CONFIG_X86_64=y
CONFIG_64BIT=y") :which-func ("CONFIG_X86_64"))) :annotation-list ((annotation :type text :data "THIS IS AN EXAMPLE ANNOTATION.")) :date "Thu Aug 12 09:53:13 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))

(stitch-annotation :version 0 :target-list ((target :type directory :directory "/srv/sources/" :item ".")) :annotation-list ((annotation :type text :data "THIS IS SOURCES.")) :date "Sun Dec 12 09:10:18 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (*DRAFT*))

(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/dists/rhel5su4/packages/k/kernel/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/fs/nfs/read.c" :point 18494 :coding-system undecided-unix :line 724 :surround ("	 */
" "" "	ret = nfs_readpages_from_fscache(desc.ctx, inode, mapping,
					 pages, &nr_pages);") :which-func ("nfs_readpages"))) :annotation-list ((annotation :type text :data "nfs_file_read <ここでgetattrしてサーバ側で変更があれば、キャッシュをinvalidとする処理がある？>
-> generic_file_aio_read
--> <page cache layer> ... nfs_readpages
---> nfs_readpages_from_fscache|read_cache_pages")) :date "Thu Dec 30 01:30:25 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (*DRAFT* nfs-atime))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/dists/rhel5su4/packages/k/kernel/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/fs/nfs/inode.c" :point 19252 :coding-system undecided-unix :line 725 :surround ("			nfs_sync_mapping(mapping);
" "" "		invalidate_inode_pages3(mapping);
") :which-func ("nfs_revalidate_mapping"))) :annotation-list ((annotation :type text :data "ここでページキャッシュから追い出している。")) :date "Mon Jan  3 17:14:30 2011" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (nfs-atime))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/dists/rhel5su4/packages/k/kernel/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/mm/filemap.c" :point 31149 :coding-system undecided-unix :line 1100 :surround ("	if (filp)
" "" "		file_accessed(filp);
}") :which-func ("do_generic_mapping_read"))) :annotation-list ((annotation :type text :data "ここでタイムスタンプ(atime)を更新")) :date "Mon Jan  3 18:16:11 2011" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (nfs-atime))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/jet/srpmix/sources/c/corosync/1.3.1-1.fc14/pre-build/corosync-1.3.1/exec/totemconfig.c" :point 2705 :coding-system undecided-unix :line 74 :surround ("#define JOIN_TIMEOUT				50
" "" "#define MERGE_TIMEOUT				200
#define DOWNCHECK_TIMEOUT			1000"))) :annotation-list ((annotation :type text :data "0.2秒tokenが更新されていなくて、GATHERでもCOMMITでもRECOVERYでもなければ、
merge送信(gatherのことか)")) :date "Fri May 27 03:27:55 2011" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/jet/srpmix/sources/c/cluster/3.1.1-1.fc14/pre-build/cluster-3.1.1/cman/daemon/ais.c" :point 10821 :coding-system undecided-unix :line 343 :surround ("		log_printf(LOGSYS_LEVEL_DEBUG, \"ais: last memb_count = %d, current = %\"PRIuFAST32\"\\n\", last_memb_count, member_list_entries);
" "" "		send_transition_msg(last_memb_count, first_trans);
		last_memb_count = member_list_entries;") :which-func ("cman_confchg_fn"))) :annotation-list ((annotation :type text :data "この先、quorumの再計算でクラスターメッセージを送信する。
そのメッセージの先でfencingか？")) :date "Thu Jun  9 03:45:39 2011" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-cluster))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/ipv4/tcp_input.c" :point 46386 :coding-system undecided-unix :line 1430 :surround ("
" "" "	tcp_unlink_write_queue(skb, sk);
	sk_wmem_free_skb(sk, skb);") :which-func "tcp_shifted_skb")) :annotation-list ((annotation :type text :data "ackを受けてここにきてwmemを広げる。")) :date "Fri Mar  2 01:27:08 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-qdisc))

(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/^alias-rhel5su7/pre-build/multipath-tools-0.4.7.rhel5.30/libmultipath/configure.c" :point 1626 :coding-system undecided-unix :line 81 :surround ("	}
" "" "	if (mpp->pgpolicyfn && mpp->pgpolicyfn(mpp))
		return 1;") :which-func "setup_map")) :annotation-list ((annotation :type text :data "ここでpgpolicyfnを呼び出している。")) :date "Fri Mar 16 08:51:34 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/g/graphviz/2.26.0-7.el6/pre-build/graphviz-2.26.0/lib/common/shapes.c" :point 59984 :coding-system undecided-unix :line 2340 :surround ("
" "" "static void gen_fields(GVJ_t * job, node_t * n, field_t * f)
{") :which-func "gen_fields")) :annotation-list ((annotation :type text :data "ここでフィールドを書き出している。")) :date "Wed Mar 21 11:12:53 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/g/graphviz/2.26.0-7.el6/pre-build/graphviz-2.26.0/lib/common/shapes.c" :point 60586 :coding-system undecided-unix :line 2365 :surround ("	    AF[1] = add_pointf(AF[1], coord);
" "" "	    gvrender_polyline(job, AF, 2);
	}") :which-func "gen_fields")) :annotation-list ((annotation :type text :data "ここでレンダーしているのでまわりにアンカーを張れれば良い。")) :date "Wed Mar 21 11:13:29 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(define-keyword hacking-graphviz-record-field-tooltips :version 0 :keywords hacking-graphviz-record-field-tooltips :subject "recordにフィールドにtooltips/urlを定義できるようにする。

	record:field[...];

で定義できれば良い。" :date "Wed Mar 21 11:16:05 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com")
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/g/graphviz/2.26.0-7.el6/pre-build/graphviz-2.26.0/lib/common/shapes.c" :point 6263 :coding-system undecided-unix :line 167 :surround ("
" "" "static shape_desc Shapes[] = {	/* first entry is default for no such shape */
    {\"box\", &poly_fns, &p_box},"))) :annotation-list ((annotation :type text :data "形(shape)毎のハンドラ一覧。")) :date "Wed Mar 21 11:19:30 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/yamato/var/graphviz/lib/agraph/agraph.h" :point 9451 :coding-system undecided-unix :line 267 :surround ("    extern Agnode_t *agfstnode(Agraph_t * g);
" "" "    extern Agnode_t *agnxtnode(Agnode_t * n);
") :which-func "NIL")) :annotation-list ((annotation :type text :data "nextノード")) :date "Fri Mar 23 10:36:43 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/yamato/var/graphviz/lib/agraph/agraph.h" :point 9405 :coding-system undecided-unix :line 266 :surround ("    extern Agnode_t *agsubnode(Agraph_t * g, Agnode_t * n, int createflag);
" "" "    extern Agnode_t *agfstnode(Agraph_t * g);
    extern Agnode_t *agnxtnode(Agnode_t * n);") :which-func "NIL")) :annotation-list ((annotation :type text :data "firstノード")) :date "Fri Mar 23 10:37:49 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/yamato/var/graphviz/lib/agraph/agraph.h" :point 10736 :coding-system undecided-unix :line 298 :surround ("    extern int aghtmlstr(char *);
" "" "    extern char *agstrbind(Agraph_t * g, char *);
    extern int agstrfree(Agraph_t *, char *);") :which-func "NIL")) :annotation-list ((annotation :type text :data "== intern")) :date "Fri Mar 23 10:39:02 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/yamato/var/graphviz/lib/agraph/agraph.h" :point 11113 :coding-system undecided-unix :line 307 :surround ("	Dict_t *dict;		/* shared dict to interpret attr field */
" "" "	char **str;		/* the attribute string values */
    };") :which-func "NIL")) :annotation-list ((annotation :type text :data "indexでアクセスする。")) :date "Fri Mar 23 10:40:38 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/g/graphviz/2.26.0-7.el6/pre-build/graphviz-2.26.0/lib/cgraph/id.c" :point 2138 :coding-system undecided-unix :line 91 :surround ("
" "" "int agmapnametoid(Agraph_t * g, int objtype, char *str,
		  unsigned long *result, int createflag)") :which-func "agmapnametoid")) :annotation-list ((annotation :type text :data "ここでidを作る。")) :date "Fri Mar 23 13:39:01 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_monitor.c" :point 16721 :coding-system undecided-unix :line 635 :surround ("
" "" "        /* Make sure anyone waiting wakes up now */
        virCondSignal(&mon->notify);") :which-func "qemuMonitorIO")) :annotation-list ((annotation :type text :data "ここでqemuとのソケット切れを処理している。")) :date "Mon Mar 26 12:26:01 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-libvirt))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_process.c" :point 106565 :coding-system undecided-unix :line 3424 :surround ("        /* we can't stop the operation even if the script raised an error */
" "" "        virHookCall(VIR_HOOK_DRIVER_QEMU, vm->def->name,
                    VIR_HOOK_QEMU_OP_RELEASE, VIR_HOOK_SUBOP_END, NULL, xml);") :which-func "qemuProcessStop")) :annotation-list ((annotation :type text :data "コマンドを呼べる。")) :date "Mon Mar 26 12:32:36 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-libvirt))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_monitor.c" :point 15231 :coding-system undecided-unix :line 592 :surround ("                            _(\"Invalid file descriptor while waiting for monitor\"));
" "" "            eof = 1;
            events &= ~VIR_EVENT_HANDLE_ERROR;") :which-func "qemuMonitorIO")) :annotation-list ((annotation :type text :data "ここれはtrueとすべき。")) :date "Mon Mar 26 12:35:39 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-libvirt patch-queue))

(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_monitor.c" :point 17333 :coding-system undecided-unix :line 651 :surround ("        VIR_DEBUG(\"Triggering error callback\");
" "" "        (errorNotify)(mon, vm);
    } else {") :which-func "qemuMonitorIO")) :annotation-list ((annotation :type text :data "???")) :date "Mon Mar 26 12:37:03 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-libvirt))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_monitor.c" :point 16931 :coding-system undecided-unix :line 640 :surround ("        VIR_DEBUG(\"Triggering EOF callback\");
" "" "        (eofNotify)(mon, vm);
    } else if (error) {") :which-func "qemuMonitorIO")) :annotation-list ((annotation :type text :data "=> qemuProcessHandleMonitorEOF")) :date "Mon Mar 26 12:37:32 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-libvirt))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/q/qemu-kvm/0.12.1.2-2.209.el6/pre-build/qemu-kvm-0.12.1.2/hw/wdt_i6300esb.c" :point 6042 :coding-system undecided-unix :line 181 :surround ("        /* What to do at the end of stage 1? */
" "" "        switch (d->int_type) {
        case INT_TYPE_IRQ:") :which-func "i6300esb_timer_expired")) :annotation-list ((annotation :type text :data "ウォッチドッグにひっかかった場合ここでstderrに記録する。
stderrは誰が回収してくれるのか？")) :date "Fri Mar 30 18:04:33 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/q/qemu-kvm/0.12.1.2-2.209.el6/pre-build/qemu-kvm-0.12.1.2/qemu-options.hx" :point 69457 :coding-system undecided-unix :line 1948 :surround ("
" "" "DEF(\"watchdog-action\", HAS_ARG, QEMU_OPTION_watchdog_action, \\
    \"-watchdog-action reset|shutdown|poweroff|pause|debug|none\\n\" \\"))) :annotation-list ((annotation :type text :data "qemuの起動オプションに-watchdog ...をつけるとwatchdogタイムアウト時の挙動を
指定できる。")) :date "Tue Apr  3 14:16:17 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/q/qemu-kvm/0.12.1.2-2.209.el6/pre-build/qemu-kvm-0.12.1.2/hw/wdt_i6300esb.c" :point 6602 :coding-system undecided-unix :line 196 :surround ("            d->previous_reboot_flag = 1;
" "" "            watchdog_perform_action(); /* This reboots, exits, etc */
            i6300esb_reset(&d->dev.qdev);") :which-func "i6300esb_timer_expired")) :annotation-list ((annotation :type text :data "ここからスタート")) :date "Tue Apr  3 14:52:21 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 11214 :coding-system undecided-unix :line 293 :surround ("	 */
" "" "	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
	    (unsigned)sk->sk_rcvbuf) {") :which-func "sock_queue_rcv_skb")) :annotation-list ((annotation :type text :data "sk_rmem_allocはskb_set_owner_rで更新する。
すなわち受信用にskを受け入れると増加する。")) :date "Tue Apr  3 23:05:42 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 11214 :coding-system undecided-unix :line 293 :surround ("	 */
" "" "	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
	    (unsigned)sk->sk_rcvbuf) {") :which-func "sock_queue_rcv_skb")) :annotation-list ((annotation :type text :data "sk->sk_rcvbufはSO_RCVBUFによって設定できるソケット毎のリード用
メモリの上限。")) :date "Tue Apr  3 23:10:38 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 41519 :coding-system undecided-unix :line 1624 :surround ("	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
" "" "	allocated = atomic_add_return(amt, prot->memory_allocated);
") :which-func "__sk_mem_schedule")) :annotation-list ((annotation :type text :data "プロトコル単位のメモリ使用量")) :date "Tue Apr  3 23:13:03 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 41767 :coding-system undecided-unix :line 1634 :surround ("	/* Under pressure. */
" "" "	if (allocated > prot->sysctl_mem[1])
		if (prot->enter_memory_pressure)") :which-func "__sk_mem_schedule")) :annotation-list ((annotation :type text :data "/proc/sys/net/ipv4/udp_memの2番目")) :date "Tue Apr  3 23:14:24 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 41901 :coding-system undecided-unix :line 1639 :surround ("	/* Over hard limit. */
" "" "	if (allocated > prot->sysctl_mem[2])
		goto suppress_allocation;") :which-func "__sk_mem_schedule")) :annotation-list ((annotation :type text :data "/proc/sys/net/ipv4/udp_memの3番目")) :date "Tue Apr  3 23:14:41 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 42048 :coding-system undecided-unix :line 1644 :surround ("	if (kind == SK_MEM_RECV) {
" "" "		if (atomic_read(&sk->sk_rmem_alloc) < prot->sysctl_rmem[0])
			return 1;") :which-func "__sk_mem_schedule")) :annotation-list ((annotation :type text :data "ソケット単位の受信のメモリ使用量とプロトコル毎に与える「ソケット単位の受信のメモリ使用」下限の比較")) :date "Tue Apr  3 23:24:16 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_process.c" :point 89499 :coding-system undecided-unix :line 2908 :surround ("    VIR_DEBUG(\"Creating domain log file\");
" "" "    if ((logfile = qemuDomainCreateLog(driver, vm, false)) < 0)
        goto cleanup;") :which-func "qemuProcessStart")) :annotation-list ((annotation :type text :data "ここでログファイル名を決めている。")) :date "Thu Apr  5 15:00:33 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_process.c" :point 93226 :coding-system undecided-unix :line 3024 :surround ("
" "" "    if ((pos = lseek(logfile, 0, SEEK_END)) < 0)
        VIR_WARN(\"Unable to seek to end of logfile: %s\",") :which-func "qemuProcessStart")) :annotation-list ((annotation :type text :data "ログファイル末尾にシークして")) :date "Thu Apr  5 15:00:53 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/util/command.c" :point 12635 :coding-system undecided-unix :line 452 :surround ("    }
" "" "    if (childerr > 0 && prepareStdFd(childerr, STDERR_FILENO) < 0) {
        virReportSystemError(errno,") :which-func "virExecWithHook")) :annotation-list ((annotation :type text :data "標準エラー出力を差し替えている=>ログファイルへ。")) :date "Thu Apr  5 15:05:21 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/q/qemu-kvm/0.12.1.2-2.209.el6/pre-build/qemu-kvm-0.12.1.2/hw/wdt_i6300esb.c" :point 6042 :coding-system undecided-unix :line 181 :surround ("        /* What to do at the end of stage 1? */
" "" "        switch (d->int_type) {
        case INT_TYPE_IRQ:") :which-func "i6300esb_timer_expired")) :annotation-list ((annotation :type text :data "libvirtがqemuをexecveする前にstderrの配管工事をしているため
ログファイル(/var/log/libvirt/qemu/ゲストの名前.log)へ記載される。")) :date "Thu Apr  5 15:06:37 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/q/qemu-kvm/0.12.1.2-2.209.el6/pre-build/qemu-kvm-0.12.1.2/hw/watchdog.c" :point 2568 :coding-system undecided-unix :line 85 :surround ("{
" "" "    if (strcasecmp(p, \"reset\") == 0)
        watchdog_action = WDT_RESET;") :which-func "select_watchdog_action")) :annotation-list ((annotation :type text :data "watchdog_actionはqemuの引数-watchdog-actionで与える。(man qemu)")) :date "Thu Apr  5 15:09:04 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
